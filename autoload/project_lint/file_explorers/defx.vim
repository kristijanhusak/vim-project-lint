function! project_lint#file_explorers#defx#register() abort
  augroup project_lint_defx
    autocmd!
    autocmd BufEnter * if &ft ==? 'defx' | call defx#_do_action('redraw', [[]]) | endif
  augroup END
  call add(g:project_lint#callbacks, 'project_lint#file_explorers#defx#callback')
endfunction

function! project_lint#file_explorers#defx#callback(...) abort
  if &filetype ==? 'defx'
    silent! exe "call defx#_do_action('redraw', [])"
    return
  endif

  let l:defx_winnr = bufwinnr('defx')
  let l:is_defx_opened = bufwinnr('defx') > 0

  if l:defx_winnr > 0
    silent! exe printf('%wincmd w')
    silent! exe "call defx#_do_action('redraw', [])"
    silent! exe 'wincmd p'
  endif
endfunction
