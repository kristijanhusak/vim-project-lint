let s:queue = {}

function! project_lint#queue#new(job, data, linters) abort
  return s:queue.new(a:job, a:data, a:linters)
endfunction

function! s:queue.new(job, data, linters) abort
  let l:instance = copy(self)
  let l:instance.job = a:job
  let l:instance.data = a:data
  let l:instance.linters = a:linters
  let l:instance.list = {}
  let l:instance.post_project_lint_file_list = []
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
  let l:data = { 'linter': a:linter, 'file': a:file }
  if self.is_linting_project()
    call add(self.post_project_lint_file_list, l:data)
  else
    let l:id = self.run_job(a:linter.file_command(a:file), a:linter, 'on_file_stdout', a:file)
    let self.list[l:id] = l:data
  endif
  let self.files[a:file] = get(self.files, a:file, {})
  let self.files[a:file][a:linter.name] = {}
endfunction

function! s:queue.project_lint_finished(id) abort
  let l:linter = self.list[a:id].linter
  call remove(self.list, a:id)
  let l:is_queue_empty = self.is_empty()
  let l:trigger_callbacks = v:true

  if l:is_queue_empty
    call self.process_post_project_lint_file_list()
  else
    for l:running_linter_name in self.get_running_linters().project
      let l:running_linter = self.linters.get_linter(l:running_linter_name)
      for l:filetype in l:running_linter.filetype
        if index(l:linter.filetype, l:filetype) > -1
          let l:trigger_callbacks = v:false
          break
        endif
      endfor
      if !l:trigger_callbacks
        break
      endif
    endfor
  endif

  return call(self.on_single_job_finish, [l:is_queue_empty, l:trigger_callbacks])
endfunction

function! s:queue.process_post_project_lint_file_list() abort
  if len(self.post_project_lint_file_list) <=? 0
    return
  endif

  for l:post_lint_job in self.post_project_lint_file_list
    call self.add_file(l:post_lint_job.linter, l:post_lint_job.file)
    call remove(self.post_project_lint_file_list, 0)
  endfor
endfunction

function! s:queue.file_lint_finished(id, file, linter) abort
  call remove(self.list, a:id)
  let l:old_file_state = copy(get(self.data.get(), a:file, {}))
  call self.data.remove(a:linter, a:file)
  if !empty(self.files[a:file][a:linter.name])
    call self.data.add(a:linter, self.files[a:file][a:linter.name])
  endif

  let l:is_queue_empty = self.is_empty()
  let l:trigger_callbacks = v:false

  if !l:is_queue_empty
    return call(self.on_single_job_finish, [l:is_queue_empty, l:trigger_callbacks, a:file])
  endif

  for [l:linter_name, l:invalid_state] in items(self.files[a:file])
    let l:old_invalid_count = has_key(l:old_file_state, l:linter_name) ? 1 : 0
    let l:current_count = !empty(l:invalid_state) ? 1 : 0
    if l:old_invalid_count !=? l:current_count
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
    if l:job.linter.name ==? a:linter.name && l:job.file ==? a:file
      return v:true
    endif
  endfor

  for l:post_lint_job in self.post_project_lint_file_list
    if l:post_lint_job.linter.name ==? a:linter.name && l:post_lint_job.file ==? a:file
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

function! s:queue.on_file_stdout(linter, file, id, message, event) abort dict
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

    if l:item.path ==? a:file
      let self.files[a:file][a:linter.name] = l:item
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
  return self.job.start(a:cmd, {
        \ 'on_stdout': function(self[a:callback], [a:linter] + a:000, self),
        \ 'on_stderr': function(self[a:callback], [a:linter] + a:000, self),
        \ 'on_exit': function(self[a:callback], [a:linter] + a:000, self),
        \ 'cwd': g:project_lint#root
        \ })
endfunction

