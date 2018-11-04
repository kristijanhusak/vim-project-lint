#!/usr/bin/env bash

if [ ! -d "vim-themis" ]; then
  git clone https://github.com/thinca/vim-themis
fi

./vim-themis/bin/themis -r --reporter spec test/
