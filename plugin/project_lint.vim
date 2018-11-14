scriptencoding utf-8
if exists('g:loaded_project_lint')
  finish
endif
let g:loaded_project_lint = v:true

let g:project_lint#error_icon = get(g:, 'project_lint#error_icon', '✖')
let g:project_lint#warning_icon = get(g:, 'project_lint#warning_icon', '⚠')
let g:project_lint#error_icon_color = get(g:, 'project_lint#error_icon_color', 'guifg=#fb4934 ctermfg=167')
let g:project_lint#warning_icon_color = get(g:, 'project_lint#warning_icon_color', 'ctermfg=214 guifg=#fabd2f')
let g:project_lint#enabled_linters = get(g:, 'project_lint#enabled_linters', {})
let g:project_lint#linter_args = get(g:, 'project_lint#linter_args', {})
let g:project_lint#debug = get(g:, 'project_lint#debug', v:false)
let g:project_lint#cache_dir = get(g:, 'project_lint#cache_dir', '~/.cache/vim-project-lint')
let g:project_lint#echo_progress = get(g:, 'project_lint#echo_progress', v:true)
let g:project_lint#root = project_lint#utils#get_project_root()
let g:project_lint#file_explorers = project_lint#file_explorers#new()
let g:project_lint#job = project_lint#job#new()
let g:project_lint#data = project_lint#data#new()
let g:project_lint#linters = project_lint#linters#new()
let g:project_lint#queue = project_lint#queue#new(
      \ g:project_lint#job,
      \ g:project_lint#data,
      \ g:project_lint#linters
      \ )
let g:project_lint = project_lint#new(
      \ g:project_lint#linters,
      \ g:project_lint#data,
      \ g:project_lint#queue,
      \ g:project_lint#file_explorers,
      \ )

function! project_lint#statusline()
  return project_lint#utils#get_statusline()
endfunction

function! project_lint#get_data()
  return g:project_lint#data.get()
endfunction

command! -nargs=0 ProjectLintClearCache call g:project_lint#data.clear_project_cache()
command! -nargs=0 ProjectLintRun call g:project_lint.run()
command! -nargs=0 ProjectLintRunFile call g:project_lint.run_file(expand('%:p'))

augroup project_lint
  autocmd!
  autocmd VimEnter * call g:project_lint.init()
  autocmd VimLeave * call g:project_lint.on_vim_leave()
  if has('nvim') || has('8.0.1459')
    autocmd DirChanged * call project_lint.handle_dir_change(v:event)
  endif
  autocmd BufWritePost * call g:project_lint.run_file(expand('<afile>:p'))
augroup END
