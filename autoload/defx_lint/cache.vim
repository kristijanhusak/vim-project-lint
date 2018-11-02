function! defx_lint#cache#set(node, is_invalid) abort
  let l:cache_dir = s:cache(a:node, a:is_invalid, v:false)
  let l:dir = fnamemodify(a:node, ':h')

  if l:dir ==? getcwd() || !l:cache_dir
    return
  endif

  while l:dir !=? getcwd()
    call s:cache(l:dir, a:is_invalid, v:true)
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
endfunction

function s:cache(node, is_invalid, is_dir) abort
  if !has_key(g:defx_lint#cache, a:node)
    let g:defx_lint#cache[a:node] = a:is_invalid ? 1 : 0
    return v:true
  endif

  "Do not mark same thing as invalid more than once
  if a:is_invalid && !a:is_dir && g:defx_lint#cache[a:node] > 0
    return v:false
  endif

  if a:is_invalid
    let g:defx_lint#cache[a:node] += 1
    return v:true
  endif

  if g:defx_lint#cache[a:node] > 0
    let g:defx_lint#cache[a:node] -= 1
  endif

  return v:true
endfunction
