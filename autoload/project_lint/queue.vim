let s:queue = {}

function project_lint#queue#new() abort
  return s:queue.new()
endfunction

function! s:queue.new() abort
  let l:instance = copy(self)
  let l:instance.jobs = {}
  return l:instance
endfunction

function! s:queue.add(id, item) abort
  if has_key(self.jobs, a:id)
    return
  endif

  let self.jobs[a:id] = a:item
endfunction

function! s:queue.remove(id) abort
  if !has_key(self.jobs, a:id)
    return
  endif

  return remove(self.jobs, a:id)
endfunction

function! s:queue.is_empty() abort
  return len(self.jobs) ==? 0
endfunction

function! s:queue.already_linting_file(linter, file) abort
  if self.is_empty()
    return v:false
  endif

  for [l:id, l:job] in items(self.jobs)
    if l:job.linter.name ==? a:linter.name && !empty(l:job.file) && l:job.file ==? a:file
      return v:true
    endif
  endfor

  return v:false
endfunction

function! s:queue.get_running_linters() abort
  if self.is_empty()
    return []
  endif

  let l:result = []

  for [l:id, l:job] in items(self.jobs)
    call add(l:result, l:job.linter.name)
  endfor

  return l:result
endfunction
