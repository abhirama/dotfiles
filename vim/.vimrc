" 1. Auto-install vim-plug if not found
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" 2. Plugin List
call plug#begin('~/.vim/plugged')
  Plug 'tpope/vim-sensible'
  Plug 'madox2/vim-ai'
  Plug 'madox2/vim-ai-provider-google'
  
  " Blogging & Markdown
  Plug 'godlygeek/tabular'          " Required for table alignment
  Plug 'preservim/vim-markdown'     " Markdown syntax
  Plug 'reedes/vim-pencil'          " Prose optimization
call plug#end()

" 2a. vim-ai Configuration
let g:vim_ai_roles_config_file = '~/.config/vim-ai.ini'
let g:vim_ai_debug = 1
let g:vim_ai_debug_log_file = '/tmp/vim_ai_debug.log'

" 3. General Settings
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" --- Markdown & Hugo Settings ---
let g:vim_markdown_frontmatter = 1       " Highlight YAML frontmatter
let g:vim_markdown_toml_frontmatter = 1  " Highlight TOML frontmatter
let g:vim_markdown_folding_disabled = 1  " Keep markdown files flat by default

" --- Blogging Mode & Word Count ---
function! WordCount()
  let l:counts = wordcount()
  if has_key(l:counts, 'visual_words')
    return l:counts.visual_words . " words (selected)"
  else
    return l:counts.words . " words"
  endif
endfunction

let g:blogging_mode = 0

function! ToggleBloggingMode()
  if g:blogging_mode == 0
    let g:blogging_mode = 1
    setlocal spell spelllang=en_us
    setlocal wrap
    setlocal linebreak
    setlocal nonumber
    setlocal norelativenumber
    setlocal signcolumn=no
    " Statusline with Word Count
    set statusline=%f\ %h%m%r%=%{WordCount()}\ %l,%c\ %P
    set laststatus=2
    PencilSoft
    echo "Blogging Mode: ON"
  else
    let g:blogging_mode = 0
    setlocal nospell
    setlocal nowrap
    setlocal number
    setlocal relativenumber
    setlocal signcolumn=yes
    set statusline&          " Reset statusline
    PencilOff
    echo "Blogging Mode: OFF"
  endif
endfunction

" Enable Blogging Mode with Space + b
nnoremap <leader>b :call ToggleBloggingMode()<CR>
