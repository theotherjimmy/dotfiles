set -e

getws() {
    if [[ -v SSH_CLIENT ]]; then
        cut -d ' ' -f 1 <<< "$SSH_CLIENT" | tr '.' '-'
    elif [[ -v NIRI_SOCKET ]]; then
        niri msg --json workspaces \
        | jq -r '.[] | select(.is_focused) |.name' \
        | cut -d: -f 1
    fi
}
ws=$(getws)

if [[ $# -gt 0 ]]; then
  files=("$@")
else
  readarray -t files < <(sk -m)
fi

if [[ $ws != "" ]] ; then
  if [[ -e $XDG_RUNTIME_DIR/kakoune/$ws ]] ; then
    exec kak -c "$ws" "${files[@]}"
  else
    exec kak -s "$ws" "${files[@]}"
  fi
else
  exec kak "${files[@]}"
fi
