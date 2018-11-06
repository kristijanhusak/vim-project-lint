let s:govet = copy(project_lint#base_linter#get())
let s:govet.name = 'govet'
let s:govet.stream = 'stderr'
let s:govet.filetype = ['go']

function! s:govet.check_executable() abort
  if executable('go')
    return self.set_cmd('go vet')
  endif

  return self.set_cmd('')
endfunction

call g:project_lint#linters.add(s:govet.new())
