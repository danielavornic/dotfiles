#!/bin/sh
# Sync my Herdr desktop app config between these dotfiles and the app's folder on Windows.
#
#   sh sync.sh pull   app -> dotfiles  (after changing settings, keys or a mod in the app)
#   sh sync.sh push   dotfiles -> app  (new machine, or after herdr-zoo's deploy.sh so these win)
#   sh sync.sh zoo    pull herdr-zoo, deploy it, then push (the one command for zoo updates)
#
# Only the files listed below are synced. The app's own state (shared.json, view.json,
# layouts/.state/, ...) is left alone. herdr-zoo's layouts and its tab bar get small patches
# on push (see "Patches to herdr-zoo"), re-applied after every zoo deploy.
# HERDR_APP_HOME overrides the app folder (default: %USERPROFILE%\.config\herdr-app).
# Needs jq for the layout patches.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
if [ -z "${HERDR_APP_HOME:-}" ]; then
  win_home=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
  HERDR_APP_HOME="$(wslpath "$win_home")/.config/herdr-app"
fi
app=$HERDR_APP_HOME

FILES="settings.json keys.json programs.json themes/kanagawa.json"
MODS="tmux-prefix tab-autoname panel-keys better-changes"
# Written into every mod folder by the app for editors; not part of the mod.
SKIP="gpui-kit.d.ts jsconfig.json"

# Herdr hot-reloads on change: write a temp file beside the target and rename it over,
# so the app never reads a half-written file.
put() { # src dst
  mkdir -p "$(dirname "$2")"
  cp "$1" "$2.sync-tmp" && mv -f "$2.sync-tmp" "$2"
}

copy_mod() { # from-dir to-dir
  mkdir -p "$2"
  for f in "$1"/*; do
    name=$(basename "$f")
    case " $SKIP " in *" $name "*) continue ;; esac
    if [ -d "$f" ]; then cp -r "$f" "$2/"; else put "$f" "$2/$name"; fi
  done
}

check_mod() { # mod name
  if command -v herdr-app.exe >/dev/null 2>&1 && [ -d "$app/mods/$1" ]; then
    herdr-app.exe check "$(wslpath -w "$app/mods/$1")"
  fi
}

# ---- Patches to herdr-zoo -------------------------------------------------------------

# Layouts to patch:
#  - host tab-autoname and panel-keys (invisible floating blocks: mods only run when a
#    layout shows them)
#  - focused pane outline in a muted grey instead of the accent blue
#  - square corners everywhere (radius 0)
PATCH_LAYOUTS="zoo zoo-top"
PANE_FOCUS_COLOR="input"
CORNER_RADIUS=0
HOSTED_BLOCKS='[
  { "id": "tab-autoname", "content": { "mod": "tab-autoname" }, "edge": "bottom", "align": "end" },
  { "id": "panel-keys", "content": { "mod": "panel-keys" }, "edge": "bottom", "align": "start" }
]'

patch_layout() { # layout name
  f="$app/layouts/$1.json"
  [ -f "$f" ] || return 0
  command -v jq >/dev/null 2>&1 || { echo "jq missing: layout $1 not patched" >&2; return 0; }
  # better-changes (munza/herdr-mods) replaces the built-in Changes panel when installed.
  if [ -d "$app/mods/better-changes" ]; then bc=true; else bc=false; fi
  patched=$(jq --argjson bc "$bc" --argjson blocks "$HOSTED_BLOCKS" --arg focus "$PANE_FOCUS_COLOR" --argjson r "$CORNER_RADIUS" '
    walk(if type == "object" then
           (if (.focus | type) == "object" and .focus.color == "accent" then .focus.color = $focus else . end)
           | (if has("radius") then .radius = $r else . end)
           | (if $bc and .id == "changes" and .content.mod? == "changes" then .content = { "mod": "better-changes", "props": { "mode": "sidebar" } } else . end)
           # A hosted mod opened as a real block (e.g. by running its command from the CLI)
           # shows up as an empty resizable column: keep only its floating copy.
           | (if (.children | type) == "array" then .children |= map(select(((.content.mod // "") as $m | $blocks | any(.content.mod == $m)) | not)) else . end)         else . end)
    | reduce $blocks[] as $b (.; if any(.floating[]?; .id == $b.id) then . else .floating = ((.floating // []) + [$b]) end)' "$f")
  if [ "$(jq -c . "$f")" = "$(printf '%s' "$patched" | jq -c .)" ]; then return 0; fi
  printf '%s\n' "$patched" >"$f.sync-tmp" && mv -f "$f.sync-tmp" "$f"
  echo "patched layout $1 (hosted mods, focus outline, square corners)"
}

# Tab numbers (for Ctrl+1..9) in front of each tab's name in herdr-zoo's tab bar. A patch,
# not a copy of my-tabs, so zoo updates still come through.
TAB_INDEX_MARK='dotfiles: tab index'
patch_tab_index() {
  f="$app/mods/my-tabs/main.js"
  [ -f "$f" ] || return 0
  grep -q "$TAB_INDEX_MARK" "$f" && return 0
  anchor='truncate().child(c.zoomed'
  if ! grep -q "$anchor" "$f"; then
    echo "my-tabs changed upstream: tab index not added (update patch_tab_index in sync.sh)" >&2
    return 0
  fi
  sed "/$anchor/i\\
        .when(i < 9, el => el.child(div().flex_none().text_color(c.active ? t.accent : t.dim).child(String(i + 1)))) // $TAB_INDEX_MARK" "$f" >"$f.sync-tmp" \
    && mv -f "$f.sync-tmp" "$f"
  echo "added tab numbers to my-tabs"
  check_mod my-tabs
}

# Zoo view on a narrow sidebar: a column of small animals instead of clipped 122 px pens.
# Inserts patches/zoo-narrow.js before the sidebar render in herdr-zoo's mods/zoo/main.js.
ZOO_NARROW_MARK='dotfiles: zoo narrow'
patch_zoo_narrow() {
  f="$app/mods/zoo/main.js"
  [ -f "$f" ] || return 0
  grep -q "$ZOO_NARROW_MARK" "$f" && return 0
  anchor='    // props {side}: the sidebar'
  import='writeTextFile } from "herdr";'
  if ! grep -qF "$anchor" "$f" || ! grep -qF "$import" "$f" || ! grep -q '^function sprite(' "$f"; then
    echo "zoo changed upstream: narrow view not added (update patch_zoo_narrow in sync.sh)" >&2
    return 0
  fi
  awk -v anchor="$anchor" 'FNR == NR { b = b $0 "\n"; next }
    !done && index($0, anchor) == 1 { printf "%s", b; done = 1 } { print }' \
    "$here/patches/zoo-narrow.js" "$f" \
    | sed 's/writeTextFile } from "herdr";/writeTextFile, layout } from "herdr";/' >"$f.sync-tmp" \
    && mv -f "$f.sync-tmp" "$f"
  echo "added narrow sidebar view to zoo"
  check_mod zoo
}

# Chat | Terminal switch in pane headers (my-pane, claude-chat): plain text like the sidebar's
# "Agents  Zoo" switch, instead of a bordered rounded box with a blue pill.
VIEW_SWITCH_MARK='dotfiles: flat view switch'
patch_view_switch() {
  for m in my-pane claude-chat; do
    f="$app/mods/$m/main.js"
    [ -f "$f" ] || continue
    grep -q "$VIEW_SWITCH_MARK" "$f" && continue
    if ! grep -q 'h_flex()\.flex_none()\.p(2)\.gap(2)\.rounded(7)\.bg(t\.surface)\.border(1)\.border_color(t\.border)' "$f"; then
      echo "$m changed upstream: view switch not restyled (update patch_view_switch in sync.sh)" >&2
      continue
    fi
    sed '/^function viewSwitch(/,/^}/ {
      s/\.px(8)\.h(20)\.flex()\.items_center()\.rounded(5)/.h(20).flex().items_center()/
      s/el\.bg(t\.selected)\.text_color(t\.foreground)/el.text_color(t.foreground)/
      s|h_flex()\.flex_none()\.p(2)\.gap(2)\.rounded(7)\.bg(t\.surface)\.border(1)\.border_color(t\.border)|h_flex().flex_none().gap(10) /* '"$VIEW_SWITCH_MARK"' */|
    }' "$f" >"$f.sync-tmp" && mv -f "$f.sync-tmp" "$f"
    echo "restyled view switch in $m"
    check_mod "$m"
  done
}

# Status bar git (branch, Sync, PR, switch) on remote spaces, and Folder / VS Code for WSL ones
# (upstream: this computer only). patches/my-status-remote.pl edits herdr-zoo's mods/my-status/main.js; exit 2 means it changed it.
patch_my_status_remote() {
  f="$app/mods/my-status/main.js"
  [ -f "$f" ] || return 0
  rc=0
  perl "$here/patches/my-status-remote.pl" "$f" || rc=$?
  [ "$rc" = 2 ] && check_mod my-status
  [ "$rc" = 0 ] || [ "$rc" = 2 ]
}

# ---- Commands -------------------------------------------------------------------------

case "${1:-}" in
  pull)
    for f in $FILES; do
      [ -f "$app/$f" ] || { echo "skip $f (not in app)"; continue; }
      mkdir -p "$here/$(dirname "$f")"
      cp "$app/$f" "$here/$f"
    done
    for m in $MODS; do
      if [ -d "$app/mods/$m" ]; then copy_mod "$app/mods/$m" "$here/mods/$m"; else echo "skip mod $m (not in app)"; fi
    done
    echo "pulled from $app"
    git -C "$here" status --short -- . || true
    ;;
  push)
    [ -d "$app" ] || { echo "no Herdr app folder at $app (install the app first)" >&2; exit 1; }
    for f in $FILES; do
      [ -f "$here/$f" ] && put "$here/$f" "$app/$f"
    done
    for m in $MODS; do copy_mod "$here/mods/$m" "$app/mods/$m"; check_mod "$m"; done
    for l in $PATCH_LAYOUTS; do patch_layout "$l"; done
    patch_tab_index
    patch_zoo_narrow
    patch_view_switch
    patch_my_status_remote
    echo "pushed to $app"
    ;;
  zoo)
    # Update herdr-zoo: pull the repo, run its deploy.sh into the Windows app, then push mine
    # so my patches and files win again. deploy.sh calls `herdr-app check <dir>`, which in WSL
    # is herdr-app.exe with a Windows path: a temporary shim provides that.
    repo=${HERDR_ZOO:-$HOME/src/herdr-zoo}
    git -C "$repo" pull --ff-only
    shim=$(mktemp -d)
    cat >"$shim/herdr-app" <<'EOF'
#!/bin/sh
if [ "${1:-}" = check ] && [ -n "${2:-}" ]; then exec herdr-app.exe check "$(wslpath -w "$2")"; fi
exec herdr-app.exe "$@"
EOF
    chmod +x "$shim/herdr-app"
    PATH="$shim:$PATH" HERDR_APP_HOME="$app" sh "$repo/scripts/deploy.sh" || { rm -rf "$shim"; exit 1; }
    rm -rf "$shim"
    sh "$here/sync.sh" push
    ;;
  *)
    echo "usage: sh sync.sh pull|push|zoo" >&2
    exit 2
    ;;
esac
