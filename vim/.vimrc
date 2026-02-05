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
