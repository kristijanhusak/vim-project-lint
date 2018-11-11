let s:ruby = copy(project_lint#base_linter#get())
let s:ruby.name = 'ruby'
let s:ruby.stream = 'stderr'
let s:ruby.filetype = ['ruby']
let s:ruby.cmd_args = '-w -c -T1'

function! s:ruby.check_executable() abort
  if executable('ruby')
    return self.set_cmd('ruby')
  endif

  return self.set_cmd('')
endfunction

function! s:ruby.command() abort
  return project_lint#utils#xargs_lint_command('rb', self.cmd, self.cmd_args)
endfunction

call g:project_lint#linters.add(s:ruby.new())
