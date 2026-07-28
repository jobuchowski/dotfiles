export PATH=$PATH:~/.local/bin

export LANG="pl_PL.UTF-8"

if which eza >/dev/null; then
    alias ls='eza --group-directories-first --icons=always --color=always'
    ls >/dev/null
fi

alias vim='nvim'

alias mountwindows='sudo mount /dev/sda2 /mnt/windows'

s() {
    local host="$1"
    local tmux_session="preserve_connection_for_jakub"
    shift

    if (( $# > 0 )); then
        kitten ssh "$host" "$@"
    else
        kitten ssh -t "$host" \
            "if command -v tmux >/dev/null 2>&1; then
                if tmux has-session -t '$tmux_session' 2>/dev/null; then
                    exec tmux attach-session -t '$tmux_session'
                else
                    exec tmux new-session -s '$tmux_session' \
                        'if [[ -t 1 && \${TERM:-dumb} != dumb ]]; then
                             printf \"\033[1;32mCreated new tmux session: $tmux_session\033[0m\n\n\"
                         else
                             printf \"Created new tmux session: $tmux_session\n\n\"
                         fi
                         exec \"\${SHELL:-/bin/sh}\" -l'
                fi
             else
                exec \"\${SHELL:-/bin/sh}\" -l
             fi"
    fi
}

get_seed_root_dir() {
    local SEED_BASHRC_PATH=$(realpath "/home/$USER/.bashrc")
    local SEED_ROOT_DIR=$(dirname "$SEED_BASHRC_PATH")
    echo $SEED_ROOT_DIR
}

export SEED_ROOT_DIR=$(get_seed_root_dir)
