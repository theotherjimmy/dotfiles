FRE_STORE=$HOME/.local/share/lanta/desktop-names

set -x

rename() {
    NAME=$(fre --sorted --store "$FRE_STORE" | bemenu -p "Rename Workspace ")
    if [[ -n $NAME ]] ; then
      ID=$(hyprctl activeworkspace -j | jq '.id')
      #SUFFIX=$(hyprctl activeworkspace -j | jq -r '.name' | cut -d: -s -f 2-)
      hyprctl dispatch renameworkspace "$ID" "$NAME"
      fre --add "$NAME" --store "$FRE_STORE"
    fi
}

switch() {
    NAME=$(hyprctl workspaces -j \
        | jq -r '.[] | @text "\(.id) \(.name)"' \
        | bemenu -p "Switch To " \
        | awk '{print $1}')
    if [[ -n $NAME ]] ; then
      hyprctl dispatch focusworkspaceoncurrentmonitor "$NAME"
    fi
}

set_pwd() {
    SELECTED=$( \
        {
            env -C "$HOME" fd -d 2 -t d &
            awk '$1=="Host" { print "@" $2 }' ~/.ssh/config
        } \
        | bemenu -p "Set Workspace PWD")
    if [[ -n $SELECTED ]] ; then
      ID=$(hyprctl activeworkspace -j | jq '.id')
      PREFIX=$(hyprctl activeworkspace -j | jq -r '.name' | cut -d: -f 1)
      if [[ -n $ID ]] && [[ -n $PREFIX ]] ; then
          hyprctl dispatch renameworkspace "$ID" "$PREFIX:$SELECTED"
      fi
    fi
}

pwd_term() {
    CUR_WS_PWD=$(hyprctl activeworkspace -j \
        | jq -r '.name' \
        | cut -d: -s -f 2-)
    if [[ $CUR_WS_PWD == @* ]] ; then
        $term -- ssh "${CUR_WS_PWD:1}"
    elif [[ -e $CUR_WS_PWD ]] ; then
        $term -D "$CUR_WS_PWD"
    else
        $term
    fi
}

case "$1" in
    "rename")
        rename
        ;;
    "switch")
        switch
        ;;
    "set-pwd")
        set_pwd
        ;;
    "term" | "pwd-term")
        pwd_term
        ;;
    *)
        exit 1
        ;;
esac
