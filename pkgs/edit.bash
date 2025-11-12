if [[ $# -gt 0 ]]; then
  files=("$@")
else
  if ! readarray -t files < <(sk -m) ; then
    exit 1
  fi
fi
ws=$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) |.name' | cut -d: -f 1)
if [[ $ws != "" ]] ; then
  if [[ -e $XDG_RUNTIME_DIR/kakoune/$ws ]] ; then
    exec kak -c "$ws" "${files[@]}"
  else
    exec kak -s "$ws" "${files[@]}"
  fi
else
  exec kak "${files[@]}"
fi
