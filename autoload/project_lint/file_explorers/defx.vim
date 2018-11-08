let s:defx = {}

function! project_lint#file_explorers#defx#new() abort
  return s:defx.new()
endfunction

function! s:defx.new() abort
  let l:instance = copy(self)
  return l:instance
endfunction

function! s:defx.callback(...) abort
  if &filetype ==? 'defx'
    silent! exe "call defx#_do_action('redraw', [])"
    return
  endif

  let l:defx_winnr = bufwinnr('defx')

  if l:defx_winnr > 0
    silent! exe printf('%wincmd w', l:defx_winnr)
    silent! exe "call defx#_do_action('redraw', [])"
    silent! exe 'wincmd p'
  endif
endfunction
