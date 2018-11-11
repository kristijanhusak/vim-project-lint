let s:rustc = copy(project_lint#base_linter#get())
let s:rustc.name = 'rustc'
let s:rustc.stream = 'stderr'
let s:rustc.filetype = ['rust']
let s:rustc.cmd_args = '--color never --error-format short'

function! s:rustc.check_executable() abort
  if executable('rustc')
    return self.set_cmd('rustc')
  endif

  return self.set_cmd('')
endfunction

function! s:rustc.command() abort
  return project_lint#utils#xargs_lint_command('rs', self.cmd, self.cmd_args)
endfunction

call g:project_lint#linters.add(s:rustc.new())
