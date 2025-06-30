FRE_STORE=$HOME/.local/share/lanta/desktop-names

rename() {
    NAME=$(fre --sorted --store "$FRE_STORE" | bemenu -p "Rename Workspace ")
    if [[ -n $NAME ]] ; then
      ID=$(hyprctl activeworkspace -j | jq '.id')
      #SUFFIX=$(hyprctl activeworkspace -j | jq -r '.name' | cut -d: -s -f 2-)
      hyprctl dispatch renameworkspace "$ID" "$NAME"
      fre --add "$NAME" --store "$FRE_STORE"
    fi
}

select_ws() {
    hyprctl workspaces -j \
        | jq -r '.[] | @text "\(.id) \(.name)"' \
        | bemenu -p "Switch To " \
        | awk '{print $1}'
}

switch() {
    NAME=$(select_ws)
    if [[ -n $NAME ]] ; then
      hyprctl dispatch focusworkspaceoncurrentmonitor "$NAME"
    fi
}

move_to() {
    NAME=$(select_ws)
    if [[ -n $NAME ]] ; then
      hyprctl dispatch movetoworkspace "$NAME"
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

cur_pwd() {
    hyprctl activeworkspace -j \
        | jq -r '.name' \
        | cut -d: -s -f 2-
}

split_hostname() {
    if [[ $1 == @* ]] ; then
        HOST=$(echo "$1" | cut -d: -f 1)
        echo "${HOST:1}"
    fi
}

split_remote_pwd() {
    if [[ $1 == @* ]] ; then
        echo "$1" | cut -d: -s -f 2
    fi
}

pwd_term() {
    CUR_WS_PWD=$(cur_pwd)
    HOST=$(split_hostname "$CUR_WS_PWD")
    if [[ -n "$HOST" ]] ; then
        REMOTE_PWD=$(split_remote_pwd "$CUR_WS_PWD")
        if [[ -n $REMOTE_PWD ]] ; then
            exec $term -- ssh -t "${HOST}" "cd \"$REMOTE_PWD\" ; \$SHELL"
        else
            exec $term -- ssh "${HOST}"
        fi
    elif [[ -e $CUR_WS_PWD ]] ; then
        exec $term -D "$CUR_WS_PWD" fish
    else
        exec $term fish
    fi
}

pwd_edit() {
    CUR_WS_PWD=$(cur_pwd)
    HOST=$(split_hostname "$CUR_WS_PWD")
    if [[ -n "$HOST" ]] ; then
        ACTUAL_CWD=~/.mnt/"$HOST"
        mkdir -p "$ACTUAL_CWD"
        if ! mountpoint "$ACTUAL_CWD" ; then
            sshfs "$HOST": "$ACTUAL_CWD"
        fi
        REMOTE_PWD=$(split_remote_pwd "$CUR_WS_PWD")
        exec $term -D "$ACTUAL_CWD"/"$REMOTE_PWD" -- edit
    elif [[ -e $CUR_WS_PWD ]] ; then
        exec $term -D "$CUR_WS_PWD" edit
    else
        exec $term edit
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
    "edit")
        pwd_edit
        ;;
    "move-to")
        move_to
        ;;
    *)
        exit 1
        ;;
esac
