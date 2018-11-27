# Vim project lint
Project level lint status right in your favorite file explorer.

Tested on:
* Neovim 0.3.1+ - Linux
* Vim 8.0+ - Linux

## File explorers

### NERDTree
![project-lint-nerdtree](https://user-images.githubusercontent.com/1782860/48678552-217fc700-eb85-11e8-9912-a2d450f53447.png)

### defx.nvim
![project-lint-defx](https://user-images.githubusercontent.com/1782860/48678553-217fc700-eb85-11e8-805f-8a43272427a8.png)

### vimfiler.vim
![project-lint-vimfiler](https://user-images.githubusercontent.com/1782860/48678554-22185d80-eb85-11e8-92fc-97e9bb1341fa.png)

## Requirements

- Vim or Neovim with "jobs" feature
- One of these file explorers:
1. [NERDTree](https://github.com/scrooloose/nerdtree)
2. [Defx.nvim](https://github.com/Shougo/defx.nvim)
3. [Vimfiler.vim](https://github.com/Shougo/vimfiler.vim)

Optional, but highly recommended for best performance:
* [ripgrep](https://github.com/BurntSushi/ripgrep) or [ag](https://github.com/ggreer/the_silver_searcher)

## Installation
Choose your favorite package manager. If you don't have one, i recommend [vim-packager](https://github.com/kristijanhusak/vim-packager)

```vimL
function! PackagerInit()
packadd vim-packager
call packager#add('kristijanhusak/vim-packager', {'type': 'opt'})
call packager#add('kristijanhusak/vim-project-lint')

"File explorers. Choose your favorite.
"NERDTree
call packager#add('scrooloose/nerdtree')

"Defx.nvim
call packager#add('Shougo/defx.nvim')

"Vimfiler
call packager#add('Shougo/unite.vim')
call packager#add('Shougo/vimfiler.vim')
endfunction
command! PackagerInstall call PackagerInit() | call packager#install()

"NERDTree
nnoremap <Leader>n :NERDTree<CR>

"vimfiler.vim
let g:vimfiler_explorer_columns = 'project_lint:type'
nnoremap <Leader>n :VimfilerExplorer

"defx.nvim
nnoremap <Leader>n :Defx -columns=project_lint:mark:filename:type<CR>
```

## Configuration

This is the default configuration:
```vimL
"Styling
let g:project_lint#error_icon = '✖'
let g:project_lint#warning_icon = '⚠'
let g:project_lint#error_icon_color = 'guifg=#fb4934 ctermfg=167'
let g:project_lint#warning_icon_color = 'ctermfg=214 guifg=#fabd2f'

"Linter settings
"example:
" let g:project_lint#enabled_linters = {'javascript': ['eslint'], 'python': ['mypy']}
" If there's no setting provided for filetype, all available linters are used.
" If provided an empty array fora filetype, no linting is done for it.
let g:project_lint#enabled_linters = {}

"example:
"let g:project_lint#linter_args = {'mypy': '--ignore-missing-imports'}
let g:project_lint#linter_args = {}

"Folder settings
"Lint status is cached for each project in this folder.
let g:project_lint#cache_dir = '~/.cache/vim-project-lint'

" When this is left empty, all folders from $HOME and above are ignored and not linted:
" example of empty value: `['/home/kristijan', '/home', '/']`
" To allow linting these folders (not recommended), set this value to `v:false`
" Or use your own list of folders. When non-empty value is provided, above defaults are not added.
let g:project_lint#ignored_folders = []

"Other
" Echo linting progress in command line. Another way to get the progress info is to use statusline.
" example:
" set statusline+=project_lint#statusline()
let g:project_lint#echo_progress = v:true

" Prints all calls to linter commands and their responses. Mostly useful for development.
let g:project_lint#debug = v:false
```

## Available linters

| Language | Linters |
| -------- | ------- |
| Python | [mypy](https://github.com/python/mypy), [flake8](https://github.com/PyCQA/flake8) |
| Javascript | [eslint](https://github.com/eslint/eslint) |
| Go | golint, go vet, [revive](https://github.com/mgechev/revive) |
| Css, Sass, Scss | [stylelint](https://github.com/mgechev/revive) |
| Lua | luac, luacheck |
| php | php -l |
| Ruby | ruby, [rubocop](https://github.com/rubocop-hq/rubocop) |
| Rust | rustc |
| Vim | [vint](https://github.com/Kuniwak/vint) |
| Typescript | [eslint](https://github.com/eslint/eslint), [tslint](https://github.com/palantir/tslint) |

## LICENSE
MIT
