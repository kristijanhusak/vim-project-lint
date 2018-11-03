#!/usr/bin/env bash

if [ ! -d "vader.vim" ]; then
  git clone https://github.com/junegunn/vader.vim
fi

nvim -Nu <(cat << EOF
filetype off
set rtp+=vader.vim
set rtp+=.
filetype plugin indent on
syntax enable
EOF
) +Vader! test/* && echo 'All tests passed!' || echo 'Tests failed.'
