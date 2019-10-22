"" Lazim
set nocompatible
filetype off

"" Paket olarak vundle lazim
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree.git'
Plugin 'AutoComplPop'
Plugin 'surround.vim'
Plugin 'Markdown'
Plugin 'majutsushi/tagbar'
call vundle#end()

filetype plugin indent on
filetype indent on
syntax enable

set number
set fileencoding=utf-8
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
set wildmenu

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

" Backup isleri
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup
