" 1. Auto-install vim-plug if not found
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" 2. Plugin List
call plug#begin('~/.vim/plugged')
  Plug 'tpope/vim-sensible'
call plug#end()

" 3. General Settings
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
