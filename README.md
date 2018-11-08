# Vim project lint

**Note**: Still in alpha phase.

Project level lint status right in your favorite file explorer.
Currently tested only on Neovim 0.3.2-dev and Vim 8.0 on Linux

### Defx.nvim
![vim-project-lint-defx](https://user-images.githubusercontent.com/1782860/48164441-c7f4de00-e2e2-11e8-8cb5-2fc9bfc053bb.png)

Install using [vim-packager](https://github.com/kristijanhusak/vim-packager)
```vimL
  function! PackagerInit()
    packadd vim-packager
    call packager#add('kristijanhusak/vim-packager', {'type': 'opt'})
    call packager#add('kristijanhusak/vim-project-lint')
    call packager#add('Shougo/defx.nvim')
    " ... Other plugins
  endfunction

  command! PackagerInstall call PackagerInit() | call packager#install()
```

Or [vim-plug](https://github.com/junegunn/vim-plug)
```vimL
  Plug 'kristijanhusak/vim-project-lint'
  Plug 'Shougo/defx.nvim'
```

Start defx with column `project_lint`:
```
:Defx -columns=project_lint:mark:filename:type
```

### NERDTree
![vim-project-lint-nerdtree](https://user-images.githubusercontent.com/1782860/48164446-cf1bec00-e2e2-11e8-86c8-af8b360698ad.png)
Install using [vim-packager](https://github.com/kristijanhusak/vim-packager)
```vimL
  function! PackagerInit()
    packadd vim-packager
    call packager#add('kristijanhusak/vim-packager', {'type': 'opt'})
    call packager#add('kristijanhusak/vim-project-lint')
    call packager#add('scrooloose/nerdtree')
    " ... Other plugins
  endfunction

  command! PackagerInstall call PackagerInit() | call packager#install()
```

Or [vim-plug](https://github.com/junegunn/vim-plug)
```vimL
  Plug 'kristijanhusak/vim-project-lint'
  Plug 'scrooloose/nerdtree'
```
That's all!

### Vimfiler.vim
![vim-project-lint-vimfiler](https://user-images.githubusercontent.com/1782860/48164449-d2af7300-e2e2-11e8-8d6a-f2e5d862c60a.png)

Install using [vim-packager](https://github.com/kristijanhusak/vim-packager)
```vimL
  function! PackagerInit()
    packadd vim-packager
    call packager#add('kristijanhusak/vim-packager', {'type': 'opt'})
    call packager#add('kristijanhusak/vim-project-lint')
    call packager#add('Shougo/unite.vim')
    call packager#add('Shougo/vimfiler.vim')
    " ... Other plugins
  endfunction

  command! PackagerInstall call PackagerInit() | call packager#install()

  let g:vimfiler_explorer_columns = 'project_lint:type'
```

Or [vim-plug](https://github.com/junegunn/vim-plug)
```vimL
  Plug 'kristijanhusak/vim-project-lint'
  Plug 'Shougo/unite.vim'
  Plug 'Shougo/vimfiler.vim'

  let g:vimfiler_explorer_columns = 'project_lint:type'
```

Start Vimfiler:
```
:VimfilerExplorer
```
