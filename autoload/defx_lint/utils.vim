function! defx_lint#utils#echo_line(text) abort
  silent! exe 'redraw'
  echom a:text
endfunction

let s:statusline = ''

function! defx_lint#utils#get_statusline() abort
  return s:statusline
endfunction

function! defx_lint#utils#set_statusline(...) abort
  let l:running_linters = g:defx_lint#queue.get_running_linters()
  if empty(l:running_linters)
    let s:statusline = ''
    return v:false
  endif

  let l:text = a:0 > 0 ? 'file' : 'project'
  let s:statusline = printf('Linting %s with "%s"', l:text, join(l:running_linters, ', '))
endfunction

function! defx_lint#utils#parse_unix(item) abort
  if matchstr(a:item, ':') ==? ''
    return ''
  endif

  let l:items = split(a:item, ':')
  if len(l:items) <=? 0
    return ''
  endif

  if stridx(l:items[0], getcwd()) > -1
    return l:items[0]
  endif

  return printf('%s/%s', getcwd(), l:items[0])
endfunction

let s:extensions_found = {}
function! defx_lint#utils#find_extension(extension) abort
  if has_key(s:extensions_found, a:extension)
    return s:extensions_found[a:extension]
  endif
  let l:items = s:find_extension(a:extension)
  if len(l:items) > 0
    let s:extensions_found[a:extension] = l:items[0]
    return l:items[0]
  endif

  return ''
endfunction

function! defx_lint#utils#debug(msg) abort
  if !get(g:, 'defx_lint#debug', v:false)
    return
  endif

  return defx_lint#utils#echo_line(a:msg)
endfunction

function s:find_extension(extension) abort
  if executable('rg')
    return systemlist(printf("rg --files --glob '**/*.%s'", a:extension))
  endif

  if executable('ag')
    return systemlist(printf('ag -g "^.*\.%s$"', a:extension))
  endif

  return glob(printf('**/*.%s', a:extension), v:false, v:true)
endfunction
