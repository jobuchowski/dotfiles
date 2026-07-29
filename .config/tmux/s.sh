s() {
    local host="$1"
    local tmux_base="preserve_connection_for_jakub"
    local tmux_socket="jakub"
    local remote_script_path="$SEED_ROOT_DIR/.config/tmux/s-remote.sh"
    local remote_script

    shift || true

    if [[ -z "$host" ]]; then
        printf 'Usage: s <host> [command]\n' >&2
        return 2
    fi

    # Run explicitly supplied commands normally, without tmux.
    if (( $# > 0 )); then
        kitten ssh "$host" "$@"
        return
    fi

    remote_script=$(
        printf 'tmux_base=%q\ntmux_socket=%q\n' "$tmux_base" "$tmux_socket"
        cat "$remote_script_path"
    )

    kitten ssh -t "$host" \
        "bash -lc $(printf '%q' "$remote_script")"
}
