# Dev containers for whatever folder you're in. Sourced from ~/.zshrc.
#
# dc-root finds the container: $DC_WORKSPACE if set; else, walking up from $PWD
# (inside $HOME), the first folder with a .devcontainer, or the one sibling that
# has one (a container that mounts its parent, like railpen's harness-agent).
#
#   dc-up / dc-rebuild     start it (rebuild: from scratch)
#   dc-run <cmd...>        start it if needed, then run cmd inside (dc-run claude)
#   dc-exec <cmd...>       run cmd inside a running container
#   dc-sh                  a shell inside
#   dc-down                stop it
#   dc-forward [port]      localhost:port -> the container's port (default 5173)
#
# Herdr's + menu runs `dc-run claude` (~/.config/herdr-app/programs.json on Windows).
# These are functions, not aliases, because Herdr's launcher doesn't expand aliases.

dc-root() {
  [[ -n $DC_WORKSPACE ]] && { print -r -- $DC_WORKSPACE; return; }
  local d=${1:-$PWD} hits
  while [[ $d == $HOME/* ]]; do
    [[ -e $d/.devcontainer || -e $d/.devcontainer.json ]] && { print -r -- $d; return; }
    hits=( ${d:h}/*(N/e:'[[ -e $REPLY/.devcontainer ]]':) )
    (( $#hits == 1 )) && { print -r -- $hits[1]; return; }
    d=${d:h}
  done
  print -u2 "dc: no dev container for $PWD (set DC_WORKSPACE)"
  return 1
}

dc-up()      { local r; r=$(dc-root) || return; devcontainer up --workspace-folder "$r" "$@"; }
dc-rebuild() { dc-up --remove-existing-container "$@"; }
dc-exec()    { local r; r=$(dc-root) || return; devcontainer exec --workspace-folder "$r" "$@"; }
dc-sh()      { dc-exec bash "$@"; }

dc-run() {
  local r; r=$(dc-root) || return
  echo "dc: starting $r ..."
  devcontainer up --workspace-folder "$r" >/dev/null || { echo "dc: devcontainer up failed for $r" >&2; return 1; }
  devcontainer exec --workspace-folder "$r" "$@"
}

dc-down() {
  local r ids; r=$(dc-root) || return
  ids=$(docker ps -q --filter "label=devcontainer.local_folder=$r")
  [[ -n $ids ]] || { echo "dc: nothing running for $r"; return 0; }
  docker stop ${=ids}
}

dc-forward() {
  local r ip port=${1:-5173}; r=$(dc-root) || return
  ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    "$(docker ps -q --filter "label=devcontainer.local_folder=$r")") || return
  echo "localhost:$port -> $ip:$port (Ctrl-C to stop)"
  socat TCP-LISTEN:"$port",fork,reuseaddr TCP:"$ip":"$port"
}
