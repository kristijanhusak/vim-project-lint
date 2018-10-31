function! defx_lint#cache#put(node, is_invalid) abort
  let g:defx_lint#cache[a:node] = a:is_invalid
endfunction

function! defx_lint#cache#remove(node) abort
  call s:remove_from_cache(a:node)

  let l:index = index(g:defx_lint#nodes, a:node)
  if l:index > -1
    call remove(g:defx_lint#nodes, l:index)
  endif

  for l:path in keys(g:defx_lint#cache)
    if escape(a:node, '/') =~? printf('^%s', escape(l:path, '/'))
      call s:remove_from_cache(l:path)
    endif
  endfor
endfunction

function s:remove_from_cache(item) abort
  if has_key(g:defx_lint#cache, a:item)
    call remove(g:defx_lint#cache, a:item)
  endif
endfunction
