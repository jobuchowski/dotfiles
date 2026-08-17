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

# mdfried (0.22.4) restores nothing on exit: it leaves DECAWM off (CSI ?7l with
# no matching ?7h) and quits mid-OSC-66 without an ST terminator. kitty keeps
# that state, so the next TUI started in the same terminal -- nvim especially --
# repaints against a cell model the terminal disagrees with, leaving stale
# highlight on the line the cursor just left. Restore the state by hand.
# The leading ST is required: it closes the dangling OSC 66, otherwise kitty
# swallows everything below as that sequence's payload.
mdfried() {
    command mdfried "$@"
    local rc=$?
    printf '\033\\'                                        # close dangling OSC
    printf '\033[?7h'                                      # autowrap back on
    printf '\033[?25h\033[?1049l'                          # cursor on, main screen
    printf '\033[<u'                                       # pop kitty keyboard stack
    printf '\033[?2027l\033[?2048l\033[?2026l'             # width, resize, sync
    printf '\033[?1002l\033[?1003l\033[?1006l\033[?1004l'  # mouse, focus
    printf '\033[!p'                                       # DECSTR soft reset
    return $rc
}

alias mountwindows='sudo mount /dev/sda2 /mnt/windows'

source "$SEED_ROOT_DIR/.config/tmux/s.sh"
