"" Vim-plug autoload script
"curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

" Vim-plug plugin sistemi
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-sensible'
Plug 'junegunn/seoul256.vim'
Plug 'scrooloose/nerdtree.vim'

call plug#end()

set number
set fileencoding=utf-8
filetype plugin indent on
set showmode
set sc
set noincsearch
set smartcase
set ignorecase
set cursorline
set scrolloff=8
set hidden
set wrap
set autoindent
set linebreak
set showmatch
set nohlsearch

" Oklari disable et
no <Up> <Nop>
no <Down> <Nop>
no <Left> <Nop>
no <Right> <Nop>
ino <Up> <Nop>
ino <Down> <Nop>
ino <Left> <Nop>
ino <Right> <Nop>

set laststatus=2
syntax on
set relativenumber

" Tablari bosluklarla degistir
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4

" Mouse scroll
set mouse=nicr
