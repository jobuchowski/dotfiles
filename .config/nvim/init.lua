-- Neovim entry point.
--
-- ~/.vimrc holds plugin-agnostic editor settings and mappings.
-- Everything plugin- or LSP-related lives here, because vim.pack and vim.lsp
-- are Neovim-only APIs.
--
-- Load order matters: plugin globals must be set before vim.pack.add() (plugins
-- read them at load time), and ~/.vimrc must be sourced after, because it runs
-- `colorscheme afterglow` from awesome-vim-colorschemes.

-- PLUGIN GLOBALS {{{
    vim.g.airline_theme = 'zenburn'

    vim.g.NERDTreeQuitOnOpen = 1

    vim.g.UltiSnipsExpandTrigger = '<C-s>'       -- Ctrl+S to expand snippets
    vim.g.UltiSnipsJumpForwardTrigger = '<C-s>'  -- Ctrl+S to move forward through tabstops
    vim.g.UltiSnipsJumpBackwardTrigger = '<C-a>' -- Ctrl+A to move backward through tabstops
-- }}}
-- PLUGINS {{{
    -- Managed by vim.pack (built into Neovim 0.12). Missing plugins install on
    -- startup. Use :Pack update to update, :Pack del <name> after removing an
    -- entry here.
    vim.pack.add({
        'https://github.com/sjl/badwolf',
        'https://github.com/rafi/awesome-vim-colorschemes',
        'https://github.com/vim-airline/vim-airline',
        'https://github.com/vim-airline/vim-airline-themes',

        'https://github.com/junegunn/fzf',
        'https://github.com/junegunn/fzf.vim',

        'https://github.com/preservim/nerdtree',

        'https://github.com/SirVer/ultisnips',

        'https://github.com/ryanoasis/vim-devicons',

        'https://github.com/MagicDuck/grug-far.nvim',

        'https://github.com/lewis6991/gitsigns.nvim',

        -- Not an LSP client: ships the lsp/*.lua server definitions (cmd,
        -- filetypes, root markers) that vim.lsp.enable() below picks up off the
        -- runtimepath. The client itself is built into Neovim.
        'https://github.com/neovim/nvim-lspconfig',
    })
-- }}}

vim.cmd('source ~/.vimrc')

-- COMPLETION {{{
    -- Native insert-mode completion (Neovim 0.12). No plugin involved; the LSP
    -- source is attached per-client in the LspAttach autocmd below.
    vim.o.autocomplete = true
    vim.o.completeopt = 'menu,menuone,noselect,popup,fuzzy'

    -- Tab/S-Tab cycle the popup, Enter accepts. Outside the popup they behave
    -- normally.
    vim.keymap.set('i', '<Tab>', function()
        return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
    end, { expr = true })
    vim.keymap.set('i', '<S-Tab>', function()
        return vim.fn.pumvisible() == 1 and '<C-p>' or '<Tab>'
    end, { expr = true })
    vim.keymap.set('i', '<CR>', function()
        return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
    end, { expr = true })
-- }}}
-- DIAGNOSTICS {{{
    -- Neovim ships virtual_text off by default; coc showed inline messages, so
    -- turn it back on to keep the old feel.
    vim.diagnostic.config({
        virtual_text = { current_line = true },
        severity_sort = true,
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = 'E',
                [vim.diagnostic.severity.WARN]  = 'W',
                [vim.diagnostic.severity.INFO]  = 'I',
                [vim.diagnostic.severity.HINT]  = 'H',
            },
        },
    })
-- }}}
-- LSP {{{
    -- Server binaries come from packages.txt / packages-aur.txt, not from a
    -- plugin manager. nvim-lspconfig supplies the defaults; the blocks below
    -- only override what needs overriding.

    vim.lsp.config('clangd', {
        cmd = {
            'clangd',
            '--background-index',
            '--header-insertion=never',
            '--completion-style=detailed',
            -- C++20 modules support. Still experimental upstream: needs a
            -- compile_commands.json covering *every* TU in the project
            -- (including the one that builds `std` if you use `import std;`),
            -- and clangd's clang version must match the compiler that builds
            -- the project.
            '--experimental-modules-support',
            '-j=4',
        },
        -- '--clang-tidy' was dropped deliberately: running clang-tidy over
        -- module units is a known clangd crash source. Re-add once modules are
        -- stable.
    })

    vim.lsp.enable({
        'clangd',        -- C/C++          (clang)
        'ts_ls',         -- TypeScript/JS  (typescript-language-server)
        'pyright',       -- Python types   (pyright)
        'ruff',          -- Python lint    (ruff)
        'jsonls',        -- JSON           (vscode-json-languageserver)
        'intelephense',  -- PHP            (nodejs-intelephense, AUR)
    })

    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lspgroup', {}),
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            local opts = { buffer = args.buf, silent = true }

            if client:supports_method('textDocument/completion') then
                vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
                    autotrigger = true,
                })
            end

            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gD', function()
                vim.cmd('tab split')
                vim.lsp.buf.definition()
            end, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', '<leader>qf', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        end,
    })
-- }}}
-- GITSIGNS {{{
    require('gitsigns').setup {
        signs = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_', show_count = true },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        signs_staged = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_', show_count = true },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        signs_staged_enable = true,
        signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
            follow_files = true
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
            delay = 200,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
            -- Options passed to nvim_open_win
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
        },
    }
-- }}}

-- vim:foldmethod=marker:foldlevel=0
