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
- **`.vimrc`** — editor settings and mappings, sourced by Neovim (no plugin config)
- **`.config/`** — app configs: hypr, waybar, rofi, kitty, dunst, lazygit, nvim, quickshell
- **`bin/`** — custom scripts, all prefixed `seed-*`, symlinked to `~/.local/bin/`
- **`polkit/`** — polkit rules for passwordless USB mounting (installed to `/etc/polkit-1/rules.d/`)

## Key Architecture Points

### Symlink Logic
`install.sh` iterates the repo root and symlinks each item to `~/`. The `bin/` directory is handled specially: each file in `bin/` is symlinked individually into `~/.local/bin/`. This means editing files in the repo immediately affects the live system.

### Neovim Setup
Neovim only — plain Vim is not used. `~/.config/nvim/init.lua` is the entry point:
it sets plugin globals, declares plugins via **`vim.pack`** (built into Neovim
0.12), sources `~/.vimrc`, then configures completion, diagnostics, LSP and
gitsigns.

Load order is deliberate: plugin globals must precede `vim.pack.add()`, and
`.vimrc` must follow it because `colorscheme afterglow` comes from a plugin.

LSP uses the **built-in `vim.lsp` client** (`vim.lsp.config` / `vim.lsp.enable`).
`nvim-lspconfig` is present only as a data source for server definitions. Server
binaries are installed as system packages via `packages.txt` /
`packages-aur.txt`, not by a plugin manager:

Official repos are preferred; PHP is the only server with no official-repo option.

| Language | Server | Package |
|---|---|---|
| C/C++ | clangd | `clang` |
| TypeScript/JS | ts_ls | `typescript-language-server` |
| Python (types) | pyright | `pyright` |
| Python (lint) | ruff | `ruff` |
| JSON | jsonls | `vscode-json-languageserver` |
| PHP | intelephense | `nodejs-intelephense` (AUR) |

clangd runs with `--experimental-modules-support` for C++20 modules. This
requires a `compile_commands.json` covering every TU in the project, and clangd's
clang version must match the project's build compiler. `--clang-tidy` is
deliberately off — it is a known crash source on module units.

Language-specific auto-formatters still run on save via `BufWritePost` shell-outs
in `.vimrc` (independent of LSP):
- C++: `clang-format`
- PHP: `pint`
- Python: `ruff`
- TypeScript: `prettier`

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
