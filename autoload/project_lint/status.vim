let s:status = {}

function! s:status.new() abort
  let l:instance = copy(self)
  let l:instance.running = v:false
  let l:instance.finished = v:false
  return l:instance
endfunction

function! s:status.set_running(linter) abort
  let self.running = v:true
  call project_lint#utils#debug(printf(
        \ 'Running command "%s" for linter "%s".',
        \ a:linter.command(),
        \ a:linter.name
        \ ))
endfunction

function! s:status.set_running_file(linter, file) abort
  let self.running = v:true

  call project_lint#utils#debug(printf(
        \ 'Running command "%s" for linter "%s".',
        \ a:linter.file_command(a:file),
        \ a:linter.name
        \ ))
endfunction

function! s:status.set_finished() abort
  let self.running = v:false
  let self.finished = v:true
  call project_lint#utils#debug('Finished running linter.')
endfunction

function! s:status.should_lint_project() abort
  return self.has_valid_file_explorer() && !self.running && !self.finished
endfunction

function! s:status.has_valid_file_explorer() abort
  return  self.has_defx() || self.has_nerdtree() || self.has_vimfiler()
endfunction

function! s:status.has_defx() abort
  return exists('g:loaded_defx')
endfunction

function! s:status.has_nerdtree() abort
  return exists('g:loaded_nerd_tree')
endfunction

function! s:status.has_vimfiler() abort
  return exists('g:loaded_vimfiler')
endfunction

function! s:status.should_lint_file(file)
  return stridx(a:file, getcwd()) ==? 0
endfunction

function! project_lint#status#new() abort
  return s:status.new()
endfunction
