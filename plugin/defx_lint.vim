let g:defx_lint#nodes = []
let g:defx_lint#cache = {}
let g:defx_lint#status = {
      \ 'running': v:false,
      \ 'finished': v:false,
      \ }
let g:defx_lint#linters = {}

runtime! autoload/defx_lint/linters/*.vim

augroup defx_lint
  autocmd VimEnter * call defx_lint#run()
  autocmd BufWritePost * call defx_lint#run_file(expand('<afile>:p'))
  autocmd BufEnter * if &filetype ==? 'defx' | call defx#_do_action('redraw', []) | endif
augroup END
