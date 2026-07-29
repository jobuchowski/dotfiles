export PATH=$PATH:~/.local/bin

get_seed_root_dir() {
    local SEED_BASHRC_PATH=$(realpath "/home/$USER/.bashrc")
    local SEED_ROOT_DIR=$(dirname "$SEED_BASHRC_PATH")
    echo $SEED_ROOT_DIR
}

export SEED_ROOT_DIR=$(get_seed_root_dir)

export LANG="pl_PL.UTF-8"

if which eza >/dev/null; then
    alias ls='eza --group-directories-first --icons=always --color=always'
    ls >/dev/null
fi

alias vim='nvim'

alias mountwindows='sudo mount /dev/sda2 /mnt/windows'

source "$SEED_ROOT_DIR/.config/tmux/s.sh"
