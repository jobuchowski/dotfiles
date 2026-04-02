# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

**SEED** (System Environment & Dotfiles) — a complete Arch Linux desktop environment configuration using the Hyprland Wayland compositor. It manages packages, dotfiles, and utility scripts for a full dev workstation setup.

## Installation

```bash
./install.sh          # Full install: packages + symlinks
./install.sh -s       # Symlinks only (skip package installation)
./install.sh -f       # Force overwrite existing symlinks
```

The installer uses a **custom recursive symlink strategy** (not stow or chezmoi): files in the repo root are symlinked to `~/`, and files in `bin/` are symlinked to `~/.local/bin/`.

Post-install: run `nwg-look` to apply Arc GTK theme/icons, then reboot.

## Repository Structure

- **`install.sh`** — main setup script (package install, symlinking, service enablement, polkit rules)
- **`packages.txt`** — official Arch packages (pacman)
- **`packages-aur.txt`** — AUR packages (installed via yay)
- **`.bashrc` / `.bash_aliases` / `.bash_profile`** — shell config; `.bash_profile` auto-starts Hyprland on TTY1
- **`.vimrc`** — shared Vim/Neovim config (Vim-Plug, CoC LSP, language formatters)
- **`.config/`** — app configs: hypr, waybar, rofi, kitty, dunst, lazygit, nvim, quickshell
- **`bin/`** — custom scripts, all prefixed `seed-*`, symlinked to `~/.local/bin/`
- **`polkit/`** — polkit rules for passwordless USB mounting (installed to `/etc/polkit-1/rules.d/`)

## Key Architecture Points

### Symlink Logic
`install.sh` iterates the repo root and symlinks each item to `~/`. The `bin/` directory is handled specially: each file in `bin/` is symlinked individually into `~/.local/bin/`. This means editing files in the repo immediately affects the live system.

### Vim Setup
`.vimrc` uses **Vim-Plug** for plugins and **CoC** for LSP. Language-specific auto-formatters run on save:
- C++: `clang-format`
- PHP: `pint`
- Python: `ruff`
- TypeScript: `prettier`

`~/.config/nvim/init.vim` extends `.vimrc` with Neovim-only config (gitsigns).

### Utility Scripts (`bin/`)
All scripts are prefixed `seed-` and use these tools heavily:
- `hyprctl` — Hyprland IPC control
- `pamixer` — PulseAudio volume control
- `notify-send` — desktop notifications via Dunst
- `jq` — JSON parsing for Hyprland state

### Hyprland Config
`.config/hypr/hyprland.conf` sources an external `~/.config/hypr/monitors.conf` (not in repo — user-created per machine). The startup script `~/.config/hypr/scripts/startup.sh` is also external.

### Environment Variable
`SEED_ROOT_DIR` is set in `.bash_aliases` pointing to the dotfiles repo root — scripts can use this to reference repo files.
