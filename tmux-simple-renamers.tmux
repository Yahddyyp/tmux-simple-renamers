#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

get_tmux_option() {
	local option=$1
	local default_value=$2
	local option_value=$(tmux show-option -gqv "$option")
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

RENAME_SESSION="$CURRENT_DIR/scripts/tmux-rename-session"
RENAME_WINDOW="$CURRENT_DIR/scripts/tmux-rename-window"

session_key=$(get_tmux_option "@tmux-simple-renamers-session-key" "C-e")
window_key=$(get_tmux_option "@tmux-simple-renamers-window-key" "C-w")

tmux bind-key "$session_key" run-shell "tmux display-popup -E -b none -x C -y 8 -w 50 -h 4 'bash \"$RENAME_SESSION\" #S'"

tmux bind-key "$window_key" run-shell "h=\$(( \$(tmux list-windows | wc -l | tr -d ' ') + 6 )); max=\$(( \$(tmux display-message -p '#{window_height}') - 13 )); [ \$h -gt \$max ] && h=\$max; [ \$h -gt 14 ] && h=14; tmux display-popup -E -b none -x C -y 12 -w 50 -h \$h 'bash \"$RENAME_WINDOW\"'"

sesh_enabled=$(get_tmux_option "@tmux-simple-renamers-sesh-integration" "off")
if [ "$sesh_enabled" = "on" ]; then
    if ! command -v sesh >/dev/null 2>&1; then
        tmux display-message "Warning: sesh integration is enabled, but 'sesh' command not found."
    else
        SESH_SWITCHER="$CURRENT_DIR/scripts/sesh-switcher"
        sesh_switcher_key=$(get_tmux_option "@tmux-simple-renamers-sesh-switcher-key" "T")
        tmux bind-key "$sesh_switcher_key" run-shell "bash $SESH_SWITCHER"
    fi
fi

