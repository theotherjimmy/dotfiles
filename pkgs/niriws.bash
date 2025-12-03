FRE_STORE=$HOME/.local/share/lanta/desktop-names

# Rename Workspace
rename() {
    NAME=$(fre --sorted --store "$FRE_STORE" | rofi -dmenu -p "Rename Workspace ")
    if [[ -n $NAME ]] ; then
      niri msg action set-workspace-name "$NAME"
      fre --add "$NAME" --store "$FRE_STORE"
    fi
}

# Select a workspace by name
select_ws() {
    niri msg --json workspaces \
        | jq -r '.[] | select(.active_window_id != null or .name != null) | @text "\(.id) \(.name)"' \
        | rofi -dmenu -i -p "Switch To " \
        | awk '{print $1}'
}

# Select and move window to a workspace by name
switch() {
    NAME=$(select_ws)
    if [[ -n $NAME ]] ; then
      niri msg action move-window-to-workspace "$NAME"
      echo '{"Action":{"MoveWindowToWorkspace":{"focus":true,"reference":{"Id":'"$NAME"'}}}}' | socat STDIO "$NIRI_SOCKET"
    fi
}

# Select and move to a workspace by name
move_to() {
    NAME=$(select_ws)
    if [[ -n $NAME ]] ; then
      MON=$(niri msg -j focused-output | jq -r '.name')
      echo '{"Action":{"MoveWorkspaceToMonitor":{"output":"'"$MON"'","reference":{"Id":'"$NAME"'}}}}' | socat STDIO "$NIRI_SOCKET"
      echo '{"Action":{"FocusWorkspace":{"reference":{"Id":'"$NAME"'}}}}' | socat STDIO "$NIRI_SOCKET"
    fi
}

# Find (git) projects within home directory
find_projects() {
    readarray -t top_level < <(env -C "$HOME" fd -t d -d 1 .)
    env -C "$HOME" fd -t d '^\.git$' --format '{//}' -H "${top_level[@]}"
    env -C "$HOME" fd -t f '^\.subproject$' --format '{//}' -H -I "${top_level[@]}"
    awk '$1=="Host" { print "@" $2 }' ~/.ssh/config
}

cur_workspace_name() {
    niri msg --json workspaces | jq -r '.[] | select(.is_focused) |.name'
}

# Set the working directory or ssh host of the current workspace
set_pwd() {
    SELECTED=$(find_projects | env LC_ALL=C sort | rofi -dmenu -i -p "Set Workspace PWD")
    if [[ -n $SELECTED ]] ; then
      PREFIX=$(cur_workspace_name | cut -d: -f 1)
      if [[ -n $PREFIX ]] ; then
          if [[ "$PREFIX" == "null" ]] ; then
              PREFIX=$(basename "$SELECTED")
          fi
          niri msg action set-workspace-name "$PREFIX:$SELECTED"
      fi
    fi
}

# Get the current workspace's working dir or host
cur_pwd() {
    cur_workspace_name | cut -d: -s -f 2-
}

# Split off a hostname if there is one
split_hostname() {
    if [[ $1 == @* ]] ; then
        HOST=$(echo "$1" | cut -d: -f 1)
        echo "${HOST:1}"
    fi
}

# Split off the remote working directory when present
split_remote_pwd() {
    if [[ $1 == @* ]] ; then
        echo "$1" | cut -d: -s -f 2
    fi
}

# Start a terminal in the workspace's working place
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

# Start an editor selecting files in the current working place
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

# Select subcommand
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
    "new-ws")
        niri msg action focus-workspace 255
        rename
        ;;
    *)
        exit 1
        ;;
esac
