#!/bin/sh
# Sync my Herdr desktop app config between these dotfiles and the app's folder on Windows.
#
#   sh sync.sh pull   app -> dotfiles  (after changing settings, keys or a mod in the app)
#   sh sync.sh push   dotfiles -> app  (new machine, or after herdr-zoo's deploy.sh so these win)
#
# Only the files listed below are synced. The app's own state (shared.json, view.json,
# layouts/.state/, ...) and the zoo's layouts and mods are left alone.
# HERDR_APP_HOME overrides the app folder (default: %USERPROFILE%\.config\herdr-app).
set -eu

here=$(cd "$(dirname "$0")" && pwd)
if [ -z "${HERDR_APP_HOME:-}" ]; then
  win_home=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
  HERDR_APP_HOME="$(wslpath "$win_home")/.config/herdr-app"
fi
app=$HERDR_APP_HOME

FILES="settings.json keys.json programs.json themes/kanagawa.json"
MODS="tmux-prefix"
# Written into every mod folder by the app for editors; not part of the mod.
SKIP="gpui-kit.d.ts jsconfig.json"

copy_mod() { # from-dir to-dir
  mkdir -p "$2"
  for f in "$1"/*; do
    name=$(basename "$f")
    case " $SKIP " in *" $name "*) continue ;; esac
    cp -r "$f" "$2/"
  done
}

case "${1:-}" in
  pull)
    for f in $FILES; do
      [ -f "$app/$f" ] || { echo "skip $f (not in app)"; continue; }
      mkdir -p "$here/$(dirname "$f")"
      cp "$app/$f" "$here/$f"
    done
    for m in $MODS; do copy_mod "$app/mods/$m" "$here/mods/$m"; done
    echo "pulled from $app"
    git -C "$here" status --short -- . || true
    ;;
  push)
    [ -d "$app" ] || { echo "no Herdr app folder at $app (install the app first)" >&2; exit 1; }
    for f in $FILES; do
      [ -f "$here/$f" ] || continue
      mkdir -p "$app/$(dirname "$f")"
      cp "$here/$f" "$app/$f"
    done
    for m in $MODS; do
      copy_mod "$here/mods/$m" "$app/mods/$m"
      if command -v herdr-app.exe >/dev/null 2>&1; then
        herdr-app.exe check "$(wslpath -w "$app/mods/$m")"
      fi
    done
    echo "pushed to $app"
    ;;
  *)
    echo "usage: sh sync.sh pull|push" >&2
    exit 2
    ;;
esac
