let s:govet = copy(project_lint#base_linter#get())
let s:govet.name = 'govet'
let s:govet.stream = 'stderr'
let s:govet.filetype = ['go']

function! s:govet.executable() abort
  if executable('go')
    return 'go vet'
  endif

  return ''
endfunction

call g:project_lint#linters.add(s:govet.new())
