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
  let l:instance.on_finish = ''
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
  let self.files[a:file][a:linter.name] = v:true
endfunction

function! s:queue.remove(id) abort
  let l:args = []
  if has_key(self.list, a:id)
    if !empty(self.list[a:id].file)
      call add(l:args, self.list[a:id].file)
    endif
    call remove(self.list, a:id)
  endif

  if !self.is_empty()
    return
  endif

  call call(self.on_finish, l:args)
  return v:true
endfunction

function! s:queue.is_empty() abort
  return len(self.list) ==? 0
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

function! s:queue.on_stdout(linter, id, message, event) abort
  if a:event ==? 'exit'
    if has_key(self, 'vim_leaved')
      return
    endif
    return self.remove(a:id)
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
    if self.files[a:file][a:linter.name]
      call self.data.remove(a:linter, a:file)
    endif
    return self.remove(a:id)
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
      let self.files[a:file][a:linter.name] = v:false
    endif

    call self.data.add(a:linter, l:item)
  endfor
endfunction

