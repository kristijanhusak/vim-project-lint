function! project_lint#file_explorers#vimfiler#register() abort
  call add(g:project_lint#callbacks, 'project_lint#file_explorers#vimfiler#callback')
endfunction

function! project_lint#file_explorers#vimfiler#callback(...) abort
  if &filetype ==? 'vimfiler'
    return
  endif

  let l:vimfiler_winnr = bufwinnr('vimfiler')
  let l:is_vimfiler_opened = bufwinnr('vimfiler') > 0

  if l:vimfiler_winnr > 0
    silent! exe printf('%wincmd w')
    silent! exe 'wincmd p'
  endif
endfunction
