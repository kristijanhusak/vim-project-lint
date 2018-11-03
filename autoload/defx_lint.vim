function! defx_lint#run() abort
  if !g:defx_lint#status.should_lint_project()
    return
  endif

  let l:has_cache = g:defx_lint#data.check_cache()

  if l:has_cache
    call s:redraw()
  endif

  for l:linter_name in keys(g:defx_lint#linters)
    let l:linter = g:defx_lint#linters[l:linter_name]
    if l:linter.detect()
      call g:defx_lint#status.set_running(l:linter)
      call s:run_job(l:linter.command(), l:linter, 's:on_stdout')
    endif
  endfor
  call defx_lint#utils#set_statusline()
endfunction

function! defx_lint#run_file(file) abort
  for l:linter_name in keys(g:defx_lint#linters)
    let l:linter = g:defx_lint#linters[l:linter_name]
    if l:linter.detect_for_file()
      if g:defx_lint#queue.already_linting_file(l:linter, a:file)
        continue
      endif
      call g:defx_lint#status.set_running_file(l:linter, a:file)
      call s:run_job(l:linter.file_command(a:file), l:linter, 's:on_file_stdout', a:file)
    endif
  endfor
  call defx_lint#utils#set_statusline(a:file)
endfunction

function! s:on_stdout(linter, id, message, event) abort
  if a:event ==? 'exit'
    return s:job_finished(a:id)
  endif

  if a:event !=? a:linter.stream
    return
  endif

  for l:msg in a:message
    let l:item = a:linter.parse(l:msg)
    if empty(l:item)
      continue
    endif

    call g:defx_lint#data.add(a:linter, l:item)
  endfor
endfunction

function! s:on_file_stdout(linter, file, id, message, event) dict
  if !has_key(self, 'is_file_valid')
    let self.is_file_valid = v:true
  endif
  if a:event ==? 'exit'
    if self.is_file_valid
      call g:defx_lint#data.remove(a:linter, a:file)
    endif
    return s:job_finished(a:id, v:true)
  endif

  if a:event !=? a:linter.stream
    return
  endif

  for l:msg in a:message
    let l:item = a:linter.parse(l:msg)
    if empty(l:item)
      continue
    endif

    if l:item ==? a:file
      let self.is_file_valid = v:false
    endif

    call g:defx_lint#data.add(a:linter, l:item)
  endfor
endfunction

function! defx_lint#add_linter(linter) abort
  if !has_key(g:defx_lint#linters, a:linter.name)
    let g:defx_lint#linters[a:linter.name] = a:linter
  endif
endfunction

function! s:redraw() abort
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

function! s:job_finished(job_id, ...) abort
  call g:defx_lint#queue.remove(a:job_id)
  call defx_lint#utils#set_statusline(a:0 > 0)
  if !g:defx_lint#queue.is_empty()
    return
  endif

  call g:defx_lint#status.set_finished()
  call g:defx_lint#data.use_fresh_data()
  call s:redraw()
  return g:defx_lint#data.cache_to_file()
endfunction

function! s:run_job(cmd, linter, callback, ...) abort
  let l:job_id = defx_lint#job#start(a:cmd, {
        \ 'on_stdout': function(a:callback, [a:linter] + a:000),
        \ 'on_stderr': function(a:callback, [a:linter] + a:000),
        \ 'on_exit': function(a:callback, [a:linter] + a:000),
        \ })

  call g:defx_lint#queue.add(l:job_id, {
        \ 'linter': a:linter,
        \ 'file': a:0 > 0 ? a:1 : ''
        \ })
endfunction
