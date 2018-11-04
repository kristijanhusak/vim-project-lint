if exists('g:loaded_project_lint')
  finish
endif
let g:loaded_project_lint = v:true

let g:project_lint#icon = get(g:, 'project_lint#icon', '✗')
let g:project_lint#icon_color = get(g:, 'project_lint#icon_color', 'guifg=#fb4934 ctermfg=167')
let g:project_lint#exclude_linters = get(g:, 'project_lint#exclude_linters', [])
let g:project_lint#linter_args = get(g:, 'project_lint#linter_args', {})
let g:project_lint#debug = get(g:, 'project_lint#debug', v:false)
let g:project_lint#callbacks = get(g:, 'project_lint#callbacks', [])
let g:project_lint#cache_dir = get(g:, 'project_lint#cache_dir', '~/.cache/vim-project-lint')
let g:project_lint#status = project_lint#status#new()
let g:project_lint#data = project_lint#data#new()
let g:project_lint#queue = project_lint#queue#new()
let g:project_lint#linters = project_lint#linters#new()

function! project_lint#statusline()
  return project_lint#utils#get_statusline()
endfunction

function! project_lint#get_data()
  return g:project_lint#data.get()
endfunction

function! project_lint#register_file_explorer_and_run() abort
  if !g:project_lint#status.has_valid_file_explorer()
    return
  endif

  call g:project_lint#linters.load()

  if g:project_lint#status.has_defx()
    call project_lint#file_explorers#defx#register()
  endif

  if g:project_lint#status.has_nerdtree()
    call project_lint#file_explorers#nerdtree#register()
  endif

  return project_lint#run()
endfunction

augroup project_lint
  autocmd!
  autocmd VimEnter * call project_lint#register_file_explorer_and_run()
  autocmd BufWritePost * call project_lint#run_file(expand('<afile>:p'))
augroup END
