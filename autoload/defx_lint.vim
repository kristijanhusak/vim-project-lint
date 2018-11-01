function! defx_lint#run() abort
  if g:defx_lint#status.running || g:defx_lint#status.finished
    return
  endif
  for l:linter_name in keys(g:defx_lint#linters)
    let l:linter = g:defx_lint#linters[l:linter_name]
    if l:linter.Detect()
      call defx_lint#utils#set_statusline(printf('Linting project with %s...', l:linter.name))
      let g:defx_lint#status.running = v:true
      call defx_lint#job#start(l:linter.Cmd(), {
            \ 'on_stdout': function('s:on_stdout', [l:linter]),
            \ 'on_stderr': function('s:on_stdout', [l:linter]),
            \ 'on_exit': function('s:on_stdout', [l:linter]),
            \ })
    endif
  endfor
endfunction

function! defx_lint#run_file(file) abort
  for l:linter_name in keys(g:defx_lint#linters)
    let l:linter = g:defx_lint#linters[l:linter_name]
    if l:linter.DetectForFile()
      call defx_lint#utils#set_statusline(printf('Linting file with %s...', l:linter.name))
      let g:defx_lint#status.running = v:true
      call defx_lint#job#start(l:linter.FileCmd(a:file), {
            \ 'on_stdout': function('s:on_file_stdout', [l:linter, a:file]),
            \ 'on_stderr': function('s:on_file_stdout', [l:linter, a:file]),
            \ 'on_exit': function('s:on_file_stdout', [l:linter, a:file]),
            \ })
    endif
  endfor
endfunction

function! s:on_stdout(linter, id, message, event) abort
  if a:event ==? 'exit'
    let g:defx_lint#status.running = v:false
    let g:defx_lint#status.finished = v:true
    call defx_lint#utils#set_statusline('')
    call defx_lint#redraw()
    return
  endif

  if a:event !=? a:linter.stream
    return
  endif

  for l:msg in a:message
    let l:item = a:linter.Parse(l:msg)
    if l:item ==? ''
      continue
    endif

    call defx_lint#cache#set(l:item, v:true)
  endfor
endfunction

function! s:on_file_stdout(linter, file, id, message, event) dict
  if !has_key(self, 'is_file_valid')
    let self.is_file_valid = v:true
  endif
  if a:event ==? 'exit'
    if self.is_file_valid
      call defx_lint#cache#set(a:file, v:false)
    endif
    let g:defx_lint#status.running = v:false
    call defx_lint#utils#set_statusline('')
    call defx_lint#redraw()
    return
  endif

  if a:event !=? a:linter.stream
    return
  endif

  for l:msg in a:message
    let l:item = a:linter.Parse(l:msg)
    if l:item ==? ''
      continue
    endif

    if l:item ==? a:file
      let self.is_file_valid = v:false
    endif

    call defx_lint#cache#set(l:item, v:true)
  endfor
endfunction

function! defx_lint#add_linter(linter) abort
  if !has_key(g:defx_lint#linters, a:linter.name)
    let g:defx_lint#linters[a:linter.name] = a:linter
  endif
endfunction

function! defx_lint#redraw() abort
  if &filetype ==? 'defx'
    return defx#_do_action('redraw', [])
  endif

  let l:defx_winnr = bufwinnr('defx')
  let l:is_defx_opened = bufwinnr('defx') > 0

  if l:defx_winnr > 0
    silent! exe printf('%wincmd w')
    call defx#_do_action('redraw', [])
    silent! exe 'wincmd p'
  endif
endfunction
