if exists('g:loaded_project_lint')
  finish
endif
let g:loaded_project_lint = v:true

let g:project_lint#status = project_lint#status#new()
let g:project_lint#data = project_lint#data#new()
let g:project_lint#queue = project_lint#queue#new()
let g:project_lint#linters = {}
let g:project_lint#exclude_linters = get(g:, 'project_lint#exclude_linters', [])
let g:project_lint#linter_args = get(g:, 'project_lint#linter_args', {})
let g:project_lint#debug = get(g:, 'project_lint#debug', v:false)

runtime! autoload/project_lint/linters/*.vim

function! project_lint#statusline()
  return project_lint#utils#get_statusline()
endfunction

function! project_lint#get_data()
  return g:project_lint#data.get()
endfunction

augroup project_lint
  autocmd VimEnter * call project_lint#run()
  autocmd BufWritePost * call project_lint#run_file(expand('<afile>:p'))
  autocmd BufEnter * if &filetype ==? 'defx' | call defx#_do_action('redraw', []) | endif
augroup END
