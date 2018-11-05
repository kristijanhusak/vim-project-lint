let s:mypy = copy(project_lint#base_linter#get())
let s:mypy.name = 'mypy'
let s:mypy.filetype = ['python']

function! s:mypy.detect() abort
  return !empty(self.cmd) && !empty(project_lint#utils#find_extension('py'))
endfunction

function! s:mypy.executable() abort
  if executable('mypy')
    return 'mypy'
  endif

  return ''
endfunction

function! s:mypy.command() abort
  return printf('%s %s **/*.py', self.cmd, self.cmd_args)
endfunction

call g:project_lint#linters.add(s:mypy.new())
