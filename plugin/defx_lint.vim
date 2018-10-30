let g:defx_lint#data = []
let s:linted = 0

function! defx_lint#exec(path) abort
  if s:linted
    return
  endif
  let s:linted = 1
  call jobstart(['./node_modules/.bin/eslint', '--format=unix', getcwd()], {
        \ 'on_stdout': function('s:on_stdout'),
        \ 'on_stderr': function('s:on_stdout'),
        \ 'cwd': getcwd(),
        \ })
endfunction

function! s:on_stdout(id, message, event) abort
  if a:event !=? 'stdout'
    return
  endif

  for l:msg in a:message
    let l:items = split(l:msg, ':')
    if len(l:items) > 0 && index(g:defx_lint#data, l:items[0]) < 0
      call add(g:defx_lint#data, l:items[0])
    endif
  endfor

  call defx#_do_action('redraw', [])
endfunction
