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
    local tmux_socket="jakub"
    shift

    if (( $# > 0 )); then
        kitten ssh "$host" "$@"
    else
        kitten ssh -t "$host" \
            "tmux_session='$tmux_session'
             tmux_socket='$tmux_socket'
             tmux_config="\$HOME/.jakub/configs/tmux.conf"

             if command -v tmux >/dev/null 2>&1; then
                 if tmux -L \"\$tmux_socket\" has-session \
                     -t \"\$tmux_session\" 2>/dev/null; then

                     exec tmux -L \"\$tmux_socket\" \
                         attach-session -t \"\$tmux_session\"
                 else
                     exec tmux -L \"\$tmux_socket\" \
                         -f \"\$tmux_config\" \
                         new-session -s \"\$tmux_session\" \
                         'printf \"\033[1;32mCreated new tmux session: $tmux_session\033[0m\n\n\";
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
