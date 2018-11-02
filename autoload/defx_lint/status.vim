let s:status = {}

function! s:status.new() abort
  let l:instance = copy(self)
  let l:instance.running = v:false
  let l:instance.finished = v:false
  let l:instance.file = ''
  return l:instance
endfunction

function! s:status.set_running(linter) abort
  let self.running = v:true
  call defx_lint#utils#set_statusline(
        \ printf('Linting project with "%s"...', a:linter.name)
        \ )

  call defx_lint#utils#debug(printf(
        \ 'Running command "%s" for linter "%s"',
        \ a:linter.command(),
        \ a:linter.name
        \ ))
endfunction

function! s:status.set_running_file(linter, file) abort
  let self.running = v:true
  let self.file = a:file
  call defx_lint#utils#set_statusline(
        \ printf('Linting file with "%s"...', a:linter.name)
        \ )

  call defx_lint#utils#debug(printf(
        \ 'Running command "%s" for linter "%s"',
        \ a:linter.file_command(a:file),
        \ a:linter.name
        \ ))
endfunction

function! s:status.set_finished() abort
  let self.running = v:false
  let self.finished = v:true
  let self.file = ''
  call defx_lint#utils#set_statusline('')
  call defx_lint#utils#debug('Finished running linter')
endfunction

function! s:status.should_lint_project() abort
  return !self.running && !self.finished
endfunction

function! s:status.is_already_linting_file(file) abort
  return self.running && self.file ==? a:file
endfunction

function! defx_lint#status#new()
  return s:status.new()
endfunction
