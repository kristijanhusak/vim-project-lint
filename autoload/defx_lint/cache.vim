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

function! defx_lint#cache#read_file() abort
  let l:filename = s:cache_filename()
  if filereadable(l:filename)
    return json_decode(readfile(l:filename))
  endif
  return {}
endfunction

function! defx_lint#cache#save_to_file() abort
  let l:filename = s:cache_filename()

  if filereadable(l:filename)
    return writefile([json_encode(g:defx_lint#cache)], l:filename)
  endif

  let l:cache_dir = fnamemodify('~/.cache/defx-lint', ':p')
  if !isdirectory(l:cache_dir)
    call mkdir(l:cache_dir, 'p')
  endif

  return writefile([json_encode(g:defx_lint#cache)], l:filename)
endfunction

function s:cache_filename() abort
  let l:fname = printf('~/.cache/defx-lint/%s.json', tolower(substitute(getcwd(), '/', '-', 'g'))[1:])
  return fnamemodify(l:fname, ':p')
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

  if g:defx_lint#cache[a:node] <=? 0
    call remove(g:defx_lint#cache, a:node)
  endif

  return v:true
endfunction
