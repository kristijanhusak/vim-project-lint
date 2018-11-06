let s:queue = {}

function project_lint#queue#new(job, data) abort
  return s:queue.new(a:job, a:data)
endfunction

function! s:queue.new(job, data) abort
  let l:instance = copy(self)
  let l:instance.job = a:job
  let l:instance.data = a:data
  let l:instance.list = {}
  let l:instance.files = {}
  let l:instance.on_single_job_finish = ''
  return l:instance
endfunction

function! s:queue.add(linter) abort
  let l:id = self.run_job(a:linter.command(), a:linter, 'on_stdout')
  let self.list[l:id] = { 'linter': a:linter, 'file': '' }
endfunction

function! s:queue.handle_vim_leave() abort
  if self.is_empty()
    return
  endif

  let self.vim_leaved = v:true
endfunction

function! s:queue.add_file(linter, file) abort
  let l:id = self.run_job(a:linter.file_command(a:file), a:linter, 'on_file_stdout', a:file)
  let self.list[l:id] = { 'linter': a:linter, 'file': a:file }
  let self.files[a:file] = get(self.files, a:file, {})
  let self.files[a:file][a:linter.name] = 0
endfunction

function! s:queue.project_lint_finished(id) abort
  call remove(self.list, a:id)
  let l:is_queue_empty = self.is_empty()
  let l:trigger_callbacks = l:is_queue_empty ? v:true : v:false

  return call(self.on_single_job_finish, [l:is_queue_empty, l:trigger_callbacks])
endfunction

function! s:queue.file_lint_finished(id, file, linter) abort
  call remove(self.list, a:id)
  let l:old_file_state = copy(get(self.data.get(), a:file, {}))
  let l:is_file_valid = self.files[a:file][a:linter.name] ==? 0
  let l:action = l:is_file_valid ? 'remove' : 'add'
  call self.data[l:action](a:linter, a:file)

  let l:is_queue_empty = self.is_empty()
  let l:trigger_callbacks = v:false

  if !l:is_queue_empty
    return call(self.on_single_job_finish, [l:is_queue_empty, l:trigger_callbacks, a:file])
  endif

  for [l:linter_name, l:invalid_count] in items(self.files[a:file])
    let l:old_invalid_count = get(l:old_file_state, l:linter_name, 0)
    if l:old_invalid_count !=? l:invalid_count
      let l:trigger_callbacks = v:true
    endif
  endfor

  call remove(self.files, a:file)
  return call(self.on_single_job_finish, [l:is_queue_empty, l:trigger_callbacks, a:file])
endfunction

function! s:queue.is_empty() abort
  return len(self.list) ==? 0
endfunction

function! s:queue.is_linting_project() abort
  if self.is_empty()
    return v:false
  endif

  for [l:id, l:job] in items(self.list)
    if empty(l:job.file)
      return v:true
    endif
  endfor

  return v:false
endfunction

function! s:queue.already_linting_file(linter, file) abort
  if self.is_empty()
    return v:false
  endif

  for [l:id, l:job] in items(self.list)
    if l:job.linter.name ==? a:linter.name && !empty(l:job.file) && l:job.file ==? a:file
      return v:true
    endif
  endfor

  return v:false
endfunction

function! s:queue.on_stdout(linter, id, message, event) abort
  if a:event ==? 'exit'
    if has_key(self, 'vim_leaved')
      return
    endif
    return self.project_lint_finished(a:id)
  endif

  if a:event !=? a:linter.stream
    return
  endif

  for l:msg in a:message
    let l:item = a:linter.parse(l:msg)
    if empty(l:item)
      continue
    endif

    call self.data.add(a:linter, l:item)
  endfor
endfunction

function! s:queue.on_file_stdout(linter, file, id, message, event) dict
  if a:event ==? 'exit'
    if has_key(self, 'vim_leaved')
      return
    endif
    return self.file_lint_finished(a:id, a:file, a:linter)
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
      let self.files[a:file][a:linter.name] = 1
    endif
  endfor
endfunction

function! s:queue.get_running_linters() abort
  let l:result = { 'project': [], 'files': [] }
  if self.is_empty()
    return l:result
  endif

  for [l:id, l:job] in items(self.list)
    if has_key(l:job, 'file') && !empty(l:job.file)
      call add(l:result.files, l:job.linter.name)
    else
      call add(l:result.project, l:job.linter.name)
    endif
  endfor

  return l:result
endfunction

function! s:queue.run_job(cmd, linter, callback, ...) abort
  let l:cb = printf('g:project_lint#queue.%s', a:callback)
  return self.job.start(a:cmd, {
        \ 'on_stdout': funcref(l:cb, [a:linter] + a:000, self),
        \ 'on_stderr': funcref(l:cb, [a:linter] + a:000, self),
        \ 'on_exit': funcref(l:cb, [a:linter] + a:000, self),
        \ 'cwd': g:project_lint#root
        \ })
endfunction

