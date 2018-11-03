let s:vint = copy(project_lint#linters#base#get())
let s:vint.name = 'vint'
let s:vint.filetype = ['vim']
let s:vint.cmd_args = '-e'

function! s:vint.detect() abort
  return !empty(self.cmd) && len(project_lint#utils#find_extension('vim')) > 0
endfunction

function! s:vint.executable() abort
  if executable('vint')
    return 'vint'
  endif

  return ''
endfunction

call project_lint#add_linter(s:vint.new())
