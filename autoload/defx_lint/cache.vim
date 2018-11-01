function! defx_lint#cache#set(node, is_invalid) abort
  call s:cache(a:node, a:is_invalid)
  let l:dir = fnamemodify(a:node, ':h')

  if l:dir ==? getcwd()
    return
  endif

  while l:dir !=? getcwd()
    call s:cache(l:dir, a:is_invalid)
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
endfunction

function s:cache(node, is_invalid) abort
  if !has_key(g:defx_lint#cache, a:node)
    let g:defx_lint#cache[a:node] = a:is_invalid ? 1 : 0
    return
  endif

  if a:is_invalid
    let g:defx_lint#cache[a:node] += 1
    return
  endif

  if g:defx_lint#cache[a:node] > 0
    let g:defx_lint#cache[a:node] -= 1
  endif
endfunction
