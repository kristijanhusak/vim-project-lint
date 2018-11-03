if exists('g:loaded_defx_lint')
  finish
endif
let g:loaded_defx_lint = v:true

let g:defx_lint#status = defx_lint#status#new()
let g:defx_lint#data = defx_lint#data#new()
let g:defx_lint#queue = defx_lint#queue#new()
let g:defx_lint#linters = {}
let g:defx_lint#exclude_linters = get(g:, 'defx_lint#exclude_linters', [])
let g:defx_lint#linter_args = get(g:, 'defx_lint#linter_args', {})
let g:defx_lint#debug = get(g:, 'defx_lint#debug', v:false)

runtime! autoload/defx_lint/linters/*.vim

function! defx_lint#statusline()
  return defx_lint#utils#get_statusline()
endfunction

function! defx_lint#get_data()
  return g:defx_lint#data.get()
endfunction

augroup defx_lint
  autocmd VimEnter * call defx_lint#run()
  autocmd BufWritePost * call defx_lint#run_file(expand('<afile>:p'))
  autocmd BufEnter * if &filetype ==? 'defx' | call defx#_do_action('redraw', []) | endif
augroup END
