tmux_config="$HOME/.jakub/configs/tmux.conf"
create_label="Create new session"

require_tmux_or_fallback_shell() {
    command -v tmux >/dev/null 2>&1 || exec "${SHELL:-/bin/sh}" -l
}

list_available_sessions() {
    tmux -L "$tmux_socket" list-sessions \
        -F "#{session_name}|#{session_attached}" 2>/dev/null |
        awk -F '|' -v prefix="$tmux_base" \
            '$1 ~ ("^" prefix "_[0-9]+$") && $2 == 0 { print $1 }' |
        sort -V
}

# Emits "key<TAB>session" pairs, in order, so both pickers show the
# same numbering (1, 2, 3, ... then letters if there are more than 9).
numbered_available_sessions() {
    local -a keys
    local key session
    local index=0

    keys=(
        1 2 3 4 5 6 7 8 9
        a b c d e f g h i j k l m
        o p q r s t u v w x y z
    )

    while IFS= read -r session; do
        [[ -n "$session" ]] || continue
        (( index < ${#keys[@]} )) || break

        key="${keys[$index]}"
        printf '%s\t%s\n' "$key" "$session"

        index=$((index + 1))
    done <<< "$available_sessions"
}

choose_with_gum() {
    local key session picked
    local -a lines

    while IFS=$'\t' read -r key session; do
        lines+=("$key. $session")
    done < <(numbered_available_sessions)

    lines+=("n. $create_label")

    picked=$(
        printf '%s\n' "${lines[@]}" |
            gum choose \
                --header "Choose an available tmux session" \
                --height 15
    ) || return 1

    [[ -n "$picked" ]] || return 1

    # gum echoes back the whole line; drop the "1. " / "n. " prefix.
    printf '%s\n' "${picked#*. }"
}

choose_with_kitten() {
    local -a ask_args
    local key session raw_output response
    local -A key_to_session

    ask_args=(
        --type=choices
        --title="Tmux sessions"
        --message="Choose an available tmux session"
        --choice="n;green:n. $create_label"
    )
    key_to_session["n"]="$create_label"

    while IFS=$'\t' read -r key session; do
        ask_args+=(--choice="$key:$key. $session")
        key_to_session["$key"]="$session"
    done < <(numbered_available_sessions)

    raw_output=$(kitten ask "${ask_args[@]}") || return 1

    # kitten ask prints a JSON object such as
    # {"items": [], "response": "n"} -- pull out the
    # chosen key and map it back to a session name.
    response=$(
        printf '%s' "$raw_output" |
            grep -o '"response"[[:space:]]*:[[:space:]]*"[^"]*"' |
            sed -E 's/.*"response"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/'
    )

    [[ -n "$response" ]] || return 1
    [[ -n "${key_to_session[$response]+x}" ]] || return 1

    printf '%s\n' "${key_to_session[$response]}"
}

# Prints the chosen session name (or $create_label) on stdout.
# Return codes: 0 = picked, 1 = cancelled, 2 = no picker available.
pick_session() {
    if [[ -z "$available_sessions" ]]; then
        printf '%s\n' "$create_label"
    elif command -v gum >/dev/null 2>&1; then
        choose_with_gum
    elif command -v kitten >/dev/null 2>&1; then
        choose_with_kitten
    else
        return 2
    fi
}

session_is_attached() {
    local session="$1"
    local attached

    attached=$(
        tmux -L "$tmux_socket" list-sessions \
            -F "#{session_attached}" \
            -f "#{==:#{session_name},$session}" \
            2>/dev/null
    )

    [[ "$attached" != 0 ]]
}

attach_existing_session() {
    local session="$1"

    # Recheck immediately in case another client attached while
    # the menu was open. (display-message with an exact-match
    # "=name" target fails to resolve #{session_attached}, so
    # filter list-sessions instead.)
    if session_is_attached "$session"; then
        printf "Session %s was taken by another client.\n" "$session" >&2
        exit 1
    fi

    exec tmux -L "$tmux_socket" attach-session -t "=$session"
}

next_session_name() {
    local number=1

    while tmux -L "$tmux_socket" has-session -t "=${tmux_base}_${number}" 2>/dev/null; do
        number=$((number + 1))
    done

    printf '%s\n' "${tmux_base}_${number}"
}

create_and_attach_session() {
    local session pane_command

    session=$(next_session_name)

    pane_command=$(
        printf 'printf "\033[1;32mCreated new tmux session: %s\033[0m\n\n" %q; exec "${SHELL:-/bin/sh}" -l' \
            "$session"
    )

    if ! tmux -L "$tmux_socket" -f "$tmux_config" new-session -d -s "$session" "$pane_command"; then
        printf "Could not create tmux session: %s\n" "$session" >&2
        exit 1
    fi

    exec tmux -L "$tmux_socket" attach-session -t "=$session"
}

main() {
    require_tmux_or_fallback_shell

    available_sessions=$(list_available_sessions)

    local selection
    selection=$(pick_session)
    case $? in
        0) ;;
        2)
            printf "Neither gum nor the remote kitten binary is available.\n" >&2
            exec "${SHELL:-/bin/sh}" -l
            ;;
        *)
            exit 0
            ;;
    esac

    [[ -n "$selection" ]] || exit 0

    if [[ "$selection" == "$create_label" ]]; then
        create_and_attach_session
    else
        attach_existing_session "$selection"
    fi
}

main
