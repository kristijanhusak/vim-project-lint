"Note: This file has an exact copy for css and sass filetype
let s:stylelint = copy(project_lint#base_linter#get())
let s:stylelint.name = 'stylelint'
let s:stylelint.stream = 'stdout'
let s:stylelint.filetype = ['css', 'scss', 'sass']
let s:stylelint.cmd_args = '--no-color -f unix'

function! s:stylelint.check_executable() abort
  if executable('stylelint')
    return self.set_cmd('stylelint')
  endif

  return self.set_cmd('')
endfunction

function! s:stylelint.command() abort
  return printf('%s %s %s/**/*.{%s}', self.cmd, self.cmd_args, g:project_lint#root, join(self.filetype, ','))
endfunction

function! s:stylelint.file_command(file) abort
  return printf('%s %s %s', self.cmd, self.cmd_args, a:file)
endfunction

call g:project_lint#linters.add(s:stylelint.new())
