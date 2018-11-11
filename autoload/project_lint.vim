let s:lint = {}

function! project_lint#new(linters, data, queue, file_explorers) abort
  return s:lint.new(a:linters, a:data, a:queue, a:file_explorers)
endfunction

function! s:lint.new(linters, data, queue, file_explorers) abort
  let l:instance = copy(self)
  let l:instance.linters = a:linters
  let l:instance.data = a:data
  let l:instance.queue = a:queue
  let l:instance.file_explorers = a:file_explorers
  let l:instance.running = v:false
  let l:instance.queue.on_single_job_finish = function(l:instance.single_job_finished, [], l:instance)
  return l:instance
endfunction

function! s:lint.init() abort
  if !self.file_explorers.has_valid_file_explorer()
    return project_lint#utils#error('No file explorer found. Install NERDTree, defx.nvim or vimfiler.')
  endif
  call self.linters.load()
  call self.file_explorers.register()

  return self.run()
endfunction

function! s:lint.on_vim_leave() abort
  return self.queue.handle_vim_leave()
endfunction

function! s:lint.handle_dir_change(event) abort
  if a:event.scope !=? 'global'
    return a:event
  endif

  let l:new_root = project_lint#utils#get_project_root()
  if l:new_root ==? g:project_lint#root
    return a:event
  endif

  let g:project_lint#root = l:new_root
  return self.init()
endfunction

function! s:lint.run() abort
  if self.running
    return project_lint#utils#error('Project lint already running.')
  endif

  let l:has_cache = self.data.check_cache()

  if l:has_cache
    call self.file_explorers.trigger_callbacks()
  endif

  for l:linter in self.linters.get()
    if l:linter.check_executable() && l:linter.detect()
      call self.set_running(l:linter, '')
      call self.queue.add(l:linter)
    endif
  endfor
  return project_lint#utils#update_statusline()
endfunction

function! s:lint.set_running(linter, file) abort
  let self.running = v:true
  let l:cmd = !empty(a:file) ? a:linter.file_command(a:file) : a:linter.command()

  call project_lint#utils#debug(printf(
        \ 'Running command "%s" for linter "%s".',
        \ l:cmd,
        \ a:linter.name
        \ ))
endfunction

function! s:lint.run_file(file) abort
  if !self.should_lint_file(a:file)
    return
  endif

  for l:linter in self.linters.get()
    if l:linter.check_executable() && l:linter.detect_for_file()
      if self.queue.already_linting_file(l:linter, a:file)
        continue
      endif

      call self.set_running(l:linter, a:file)
      call self.queue.add_file(l:linter, a:file)
    endif
  endfor
  return project_lint#utils#update_statusline()
endfunction

function! s:lint.should_lint_file(file) abort
  return stridx(a:file, g:project_lint#root) ==? 0
endfunction

function! s:lint.single_job_finished(is_queue_empty, trigger_callbacks, ...) abort
  call project_lint#utils#debug('Finished running single linter.')
  call project_lint#utils#update_statusline()

  if a:trigger_callbacks
    call call(self.file_explorers.trigger_callbacks, a:000)
  endif

  if !a:is_queue_empty
    return
  endif

  let self.running = v:false
  call self.data.use_fresh_data()
  return self.data.cache_to_file()
endfunction
