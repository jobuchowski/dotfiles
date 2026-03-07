" Vimrc
" PLUGINS {{{
    call plug#begin('~/.vim/plugins')

    Plug 'sjl/badwolf'
    Plug 'rafi/awesome-vim-colorschemes'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'tpope/vim-commentary' " gcc - comment whole line, gc - comment in visual mode
    Plug 'ramele/agrep' " asynchronous grep
    Plug 'pangloss/vim-javascript'

    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'

    Plug 'preservim/nerdtree'

    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    Plug 'SirVer/ultisnips'

    Plug 'ryanoasis/vim-devicons'

    Plug 'MagicDuck/grug-far.nvim'

    Plug 'lewis6991/gitsigns.nvim'

    " Call :PlugInstall in vim to install plugins
    " :PlugUpdate :PlugDiff
    " :PlugClean after deleting plugin
    call plug#end()
" }}}
" GENERAL SETTINGS {{{
    " Colors {{{
        syntax enable
        colorscheme afterglow
        set t_Co=256

        " transparent background
        hi Normal guibg=NONE ctermbg=NONE

        " colors of side bar with line numbers
        hi LineNr ctermbg=NONE
        hi LineNr ctermfg=darkgrey

    " }}}
    " Misc {{{
        " enter the current millenium
        set nocompatible

        " Copying and pasting from global clipboard
        set clipboard^=unnamedplus
        set clipboard^=unnamed

        set backspace=indent,eol,start
        set mouse=a " enable use of the mouse for all modes
        set textwidth=0
        set wrapmargin=0
        set history=100 " 100 instead of 12

        " disable preview ( for example new window in YouCompleteMe plugin
        set completeopt-=preview
    " }}}
    " Spaces & tabs {{{
        set tabstop=4
        set expandtab
        set softtabstop=4
        set shiftwidth=4
        set modeline
        set modelines=1
        filetype indent on
        filetype plugin on
        set autoindent
    " }}}
    " UI Layout {{{
        set number " show current line number instead of 0 in relativenumber
        set relativenumber	" show relative line numbers
        set showcmd	" show command in bottom bar
        set cursorline	" highlight current line
        set colorcolumn=80
        set wildmenu	" autocompletion in menu with TAB
        set ruler       " cursor position in the status bar
        set lazyredraw	" buffer screen updates instead of updating it all time
        "turn off beep and visualbell
        set visualbell
        set t_vb=
        " Instead of failing a command because of unsaved changes, instead raise a
        " dialogue asking if you wish to save changed files.
        set confirm
        " set fillchars+=vert:|
        " disable cursor style changing in nvim
        if has('nvim')
            let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 0
            set guicursor=
        endif
    " }}}
    " Searching {{{
        set ignorecase	" ignore case when searching
        set smartcase   " except when using capital letters
        set incsearch	" search as characters are entered
        set hlsearch	" highlight all matches
        set showmatch	" highlight current parenthesis
        set matchpairs+=<:>
    " }}}
    " Folding {{{
        set foldmethod=indent	" fold based on indent level
        set foldnestmax=10	" max 10 depth
        set foldenable		" don't fold files by default on open
        " toggle folding:
        nnoremap <space> za
        set foldlevelstart=10	" start with fold level of 1
    " }}}
" }}}
" MAPPINGS {{{
    " Line Shortcuts {{{
        " Skip 'fake' lines - wrapped ones
        nnoremap j gj
        nnoremap k gk
        " highlight last inserted text
        nnoremap gV `[v`]
    " }}}
    " Normal Mode Shortcuts {{{
        " easier usage
        nnoremap ; :
        " ; repeats last f, F, t, T
        nnoremap \ ;
        " Easy window navigation
        map <C-h> <C-w>h
        map <C-j> <C-w>j
        map <C-k> <C-w>k
        map <C-l> <C-w>l

        noremap <C-up> <C-w>k 
        noremap <C-down> <C-w>j 
        noremap <C-left> <C-w>h 
        noremap <C-right> <C-w>l 
    " }}}
    " Insert Mode Shortcuts {{{
        " inoremap jk <ESC> 
    " }}}
    " Leader Shortcuts {{{
        " <leader> = \
        let mapleader=","	" change <leader> to ,
        nnoremap <leader>l :call ToggleNumber()<CR>
        nnoremap <leader>sv :source $MYVIMRC<CR>
        nnoremap <leader>1 :set number!<CR>
        nnoremap <leader>e :Texplore<CR>
        nnoremap <leader>/ :nohlsearch<CR>
        nnoremap <leader>2 $
        nnoremap <leader>@ ^
        vnoremap <leader>2 $
        vnoremap <leader>@ ^
        " let g:minimap_show='<leader>mm'
        " fzf shortcuts
        nnoremap <leader>f :Files<CR>
        nnoremap <leader>g :Rg<CR>

        " nerd tree showrtcuts
        nnoremap <expr> <leader>n g:NERDTree.IsOpen() ? "\:NERDTreeClose<CR>" : "\:NERDTreeFind<CR>"
    " }}}
" }}}
" AUTO GROUPS {{{
    augroup configgroup
        autocmd!
        " Change Commentary in c++ from /* */ to //
        autocmd FileType c,cpp,cs,java,php setlocal commentstring=//\ %s
        " disable auto comment continues on new line
        autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
        " Change *.asm files syntax to nasm
        autocmd BufRead,BufNewFile *.asm set filetype=nasm
        autocmd FileType asm,nasm setlocal commentstring=;%s

        " On file save, format files with pint for PHP
        autocmd BufWritePost *.php silent !`git rev-parse --show-toplevel`/vendor/bin/pint <afile>

        " On file save, format files with clang-format for C++
        autocmd BufWritePost *.cpp,*.hpp silent !clang-format -i <afile>

        " On file save, format files with ruff for Python
        autocmd BufWritePost *.py silent !ruff format <afile>

        " On file save, format files with npm script for TypeScript
        autocmd BufWritePost *.ts,*.tsx silent !npx prettier --write <afile>
    augroup END
" }}}
" BACKUPS {{{
    " Disable backups file
    set nobackup

    " Disable vim common sequense for saving.
    " By default vim writes buffer to a new file, then deletes the original.
    " Then renames the new file.
    set nowritebackup

    " Disable swp files
    set noswapfile

" }}}
" CUSTOM FUNCTIONS {{{
    function! ToggleNumber()
        if(&relativenumber == 1)
            set norelativenumber
            set number
        else
            set relativenumber
        endif
    endfunc
" }}}
" PLUGIN SETTINGS {{{
    " Airline {{{
        set laststatus=2
        let g:airline_theme = 'zenburn'
        " let g:airline_left_sep = ''
        " let g:airline_left_sep = ''
        " let g:airline_right_sep = ''
        " let g:airline_right_sep = ''
    " }}}
" YouCompleteMe {{{
    let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"
    let g:ycm_filetype_blacklist = { 'php': 1 }
    " highlight Error ctermbg=NONE ctermfg=124 cterm=bold,underline
    " highlight ErrorMsg ctermbg=124 ctermfg=15
    " Text of warnings
    highlight SyntasticWarning cterm=underline,italic
    " Indicator of warnings
    highlight SyntasticWarningSign ctermfg=172 cterm=bold
    " Indicator of errors
    highlight SyntasticErrorSign ctermfg=124 cterm=bold
    " highlight SyntasticStyleError cterm=underline,italic
    " highlight SyntasticStyleErrorSign ctermfg=25 cterm=bold
    " Text of errors
    highlight YcmErrorSection ctermbg=124 ctermfg=233 cterm=bold
" }}}
" NERDTree {{{
    " Close NERDTree when new file opens
    let NERDTreeQuitOnOpen=1
" }}}
" CoC {{{
    " Use <TAB> to select the popup menu:
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<Tab>"
    inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gD :call CocAction('jumpDefinition', 'tabe')<CR>
    nmap <silent> gr <Plug>(coc-references)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    " Apply the most preferred quickfix action to fix diagnostic on the current line
    nmap <leader>qf  <Plug>(coc-fix-current)

    nnoremap <silent> K :call ShowDocumentation()<CR>
    function! ShowDocumentation()
      if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
      else
        call feedkeys('K', 'in')
      endif
    endfunction

    let g:coc_global_extensions = [
      \ '@yaegassy/coc-intelephense',
      \ 'coc-json',
      \ 'coc-clangd',
      \ 'coc-pyright',
      \ 'coc-tsserver'
    \ ]
" }}}
" UltiSnips {{{
    " This code should go in your vimrc or init.vim
    let g:UltiSnipsExpandTrigger       = '<C-s>'    " use Ctrl+S to expand snippets
    let g:UltiSnipsJumpForwardTrigger  = '<C-s>'    " use Ctrl+S to move forward through tabstops
    let g:UltiSnipsJumpBackwardTrigger = '<C-a>'    " use Ctrl+A to move backward through tabstops
" }}}
" }}}
"
" vim:foldmethod=marker:foldlevel=0
