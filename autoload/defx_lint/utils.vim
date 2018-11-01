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

function! defx_lint#utils#parse_unix(item, ...) abort
  let l:prepend_cwd = a:0 > 0
  if matchstr(a:item, ':') ==? ''
    return ''
  endif

  let l:items = split(a:item, ':')
  if len(l:items) <=? 0
    return ''
  endif

  if !l:prepend_cwd
    return l:items[0]
  endif

  return printf('%s/%s', getcwd(), l:items[0])
endfunction
