let s:govet = copy(project_lint#linters#base#get())
let s:govet.name = 'govet'
let s:govet.stream = 'stderr'
let s:govet.filetype = ['go']

function! s:govet.detect() abort
  return !empty(self.cmd) && len(project_lint#utils#find_extension('go')) > 0
endfunction

function! s:govet.executable() abort
  if executable('go')
    return 'go vet'
  endif

  return ''
endfunction

call project_lint#add_linter(s:govet.new())
