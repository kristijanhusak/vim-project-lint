let g:defx_lint#cache = {}
let g:defx_lint#status = {
      \ 'running': v:false,
      \ 'finished': v:false,
      \ }
let g:defx_lint#linters = {}
let g:defx_lint#linter_args = get(g:, 'defx_lint#linter_args', {})
let g:defx_lint#debug = v:false

runtime! autoload/defx_lint/linters/*.vim

function defx_lint#statusline()
  return defx_lint#utils#get_statusline()
endfunction

augroup defx_lint
  autocmd VimEnter * call defx_lint#run()
  autocmd BufWritePost * call defx_lint#run_file(expand('<afile>:p'))
  autocmd BufEnter * if &filetype ==? 'defx' | call defx#_do_action('redraw', []) | endif
augroup END
