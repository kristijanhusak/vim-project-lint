function! defx_lint#utils#echo_line(text) abort
  silent! exe 'redraw'
  echom a:text
endfunction
