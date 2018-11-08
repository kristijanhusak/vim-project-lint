let s:vimfiler = {}

function! project_lint#file_explorers#vimfiler#new() abort
  return s:vimfiler.new()
endfunction

function! s:vimfiler.new() abort
  let l:instance = copy(self)
  return l:instance
endfunction

function! s:vimfiler.callback(...) abort
  if &filetype ==? 'vimfiler'
    return vimfiler#view#_redraw_screen()
  endif

  let l:vimfiler_winnr = bufwinnr('vimfiler')
  let l:is_vimfiler_opened = bufwinnr('vimfiler') > 0

  if l:vimfiler_winnr > 0
    silent! exe printf('%wincmd w')
    silent! exe 'wincmd p'
  endif
endfunction
