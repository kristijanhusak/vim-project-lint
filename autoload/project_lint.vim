function! project_lint#run() abort
  if !g:project_lint#status.should_lint_project()
    return
  endif

  let l:has_cache = g:project_lint#data.check_cache()

  if l:has_cache
    call s:trigger_callbacks()
  endif

  for l:linter in g:project_lint#linters.get()
    if l:linter.detect()
      call g:project_lint#status.set_running(l:linter)
      call s:run_job(l:linter.command(), l:linter, 's:on_stdout')
    endif
  endfor
  call project_lint#utils#set_statusline()
endfunction

function! project_lint#run_file(file) abort
  if !g:project_lint#status.should_lint_file(a:file)
    return
  endif

  for l:linter in g:project_lint#linters.get()
    if l:linter.detect_for_file()
      if g:project_lint#queue.already_linting_file(l:linter, a:file)
        continue
      endif
      call g:project_lint#status.set_running_file(l:linter, a:file)
      call s:run_job(l:linter.file_command(a:file), l:linter, 's:on_file_stdout', a:file)
    endif
  endfor
  call project_lint#utils#set_statusline()
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

    call g:project_lint#data.add(a:linter, l:item)
  endfor
endfunction

function! s:on_file_stdout(linter, file, id, message, event) dict
  if !has_key(self, 'is_file_valid')
    let self.is_file_valid = v:true
  endif
  if a:event ==? 'exit'
    if self.is_file_valid
      call g:project_lint#data.remove(a:linter, a:file)
    endif
    return s:job_finished(a:id, a:file)
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

    call g:project_lint#data.add(a:linter, l:item)
  endfor
endfunction

function! s:trigger_callbacks(...) abort
  for l:callback in g:project_lint#callbacks
    call call(l:callback, a:000)
  endfor
endfunction

function! s:job_finished(job_id, ...) abort
  call g:project_lint#queue.remove(a:job_id)
  if !g:project_lint#queue.is_empty()
    return
  endif
  call project_lint#utils#set_statusline()

  call g:project_lint#status.set_finished()
  call g:project_lint#data.use_fresh_data()
  call call('s:trigger_callbacks', a:000)
  return g:project_lint#data.cache_to_file()
endfunction

function! s:run_job(cmd, linter, callback, ...) abort
  let l:job_id = project_lint#job#start(a:cmd, {
        \ 'on_stdout': function(a:callback, [a:linter] + a:000),
        \ 'on_stderr': function(a:callback, [a:linter] + a:000),
        \ 'on_exit': function(a:callback, [a:linter] + a:000),
        \ })

  call g:project_lint#queue.add(l:job_id, {
        \ 'linter': a:linter,
        \ 'file': a:0 > 0 ? a:1 : ''
        \ })
endfunction
