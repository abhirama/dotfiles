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

" Clear any existing mapleader
let mapleader = "\<Space>"
let g:mapleader = "\<Space>"

" Set localleader to a comma or backslash if you use it
let maplocalleader = ","

" 2a. vim-ai Configuration
let g:vim_ai_roles_config_file = '~/.config/vim-ai.ini'
let g:vim_ai_debug = 1
let g:vim_ai_debug_log_file = '/tmp/vim_ai_debug.log'

" 3. General Settings
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Move between panes using Space + hjkl
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" Quick split creation
nnoremap <leader>v <C-w>v  " Space + v for Vertical split
nnoremap <leader>s <C-w>s  " Space + s for Horizontal split

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

" 1. Ensure the session directory exists
silent! !mkdir -p ~/.vim/ai_sessions

function! OpenSmartAISession()
    let l:blog_file = expand('%:p')
    let l:session_file = expand('~/.vim/ai_sessions/') . expand('%:t:r') . '.aichat'

    if &modified | write | endif

    execute 'vsplit ' . l:session_file
    set filetype=aichat

    " 1. Setup the System Role correctly if the file is new
    if line('$') == 1 && getline(1) == ''
        call setline(1, ">>> system")
        call append(line('$'), "You are a helpful proofreader for my technology blog (abhyrama.com).")
        call append(line('$'), "I will provide drafts of my posts. Focus on flow, technical clarity, and tone.")
    endif

    " 2. Add the User Role for the latest draft
    call append(line('$'), ">>> user")
    call append(line('$'), "[Draft Snapshot: " . strftime("%Y-%m-%d %H:%M") . "]")

    " 3. Smart Read: Skip the YAML header (everything between the first two '---')
    " We search for the second '---' and start reading from there.
    let l:start_line = 1
    let l:content = readfile(l:blog_file)
    let l:dash_count = 0
    for l:line in l:content
        let l:start_line += 1
        if l:line =~ '^---'
            let l:dash_count += 1
        endif
        if l:dash_count == 2 | break | endif
    endfor

    " If no YAML header found, just read the whole thing; otherwise read from start_line
    let l:lines_to_add = l:content[(l:dash_count == 2 ? l:start_line - 1 : 0):]
    call append(line('$'), l:lines_to_add)
    call append(line('$'), "---")

    normal! G
endfunction

" Shortcut to trigger the session: AI Blog
nnoremap <leader>ab :call OpenSmartAISession()<CR>

" Trigger AI Chat with Ctrl-s in .aichat files
autocmd FileType aichat nnoremap <buffer> <C-s> :AIChat<CR>
autocmd FileType aichat inoremap <buffer> <C-s> <Esc>:AIChat<CR>

" Save the AI session whenever you leave the sidecar or stop typing
autocmd BufLeave,InsertLeave,CursorHold *.aichat silent! update
