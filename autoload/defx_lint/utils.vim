function! defx_lint#utils#echo_line(text) abort
  silent! exe 'redraw'
  echom a:text
endfunction

let s:statusline = ''

function! defx_lint#utils#get_statusline()
  return s:statusline
endfunction

function! defx_lint#utils#set_statusline(text)
  let s:statusline = a:text
endfunction
