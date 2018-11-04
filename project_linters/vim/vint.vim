let s:vint = copy(project_lint#base_linter#get())
let s:vint.name = 'vint'
let s:vint.filetype = ['vim']
let s:vint.cmd_args = '-e'

function! s:vint.executable() abort
  if executable('vint')
    return 'vint'
  endif

  return ''
endfunction

call g:project_lint#linters.add(s:vint.new())
