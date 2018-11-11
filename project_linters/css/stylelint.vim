"Note: This file has an exact copy for scss and sass filetype
let s:stylelint = copy(project_lint#base_linter#get())
let s:stylelint.name = 'stylelint'
let s:stylelint.stream = 'stdout'
let s:stylelint.filetype = ['css', 'scss', 'sass']
let s:stylelint.cmd_args = '--no-color -f unix'

function! s:stylelint.check_executable() abort
  let l:local = printf('%s/node_modules/.bin/stylelint', g:project_lint#root)
  let l:global = 'stylelint'
  if executable(l:local)
    return self.set_cmd(l:local)
  endif

  if executable(l:global)
    return self.set_cmd(l:global)
  endif

  return self.set_cmd('')
endfunction

function! s:stylelint.command() abort
  return printf('%s %s %s/**/*.{%s}', self.cmd, self.cmd_args, g:project_lint#root, join(self.filetype, ','))
endfunction

function! s:stylelint.file_command(file) abort
  return printf('%s %s %s', self.cmd, self.cmd_args, a:file)
endfunction

let s:instance = s:stylelint.new()

function! project_linters#css#stylelint#get() abort
  return s:instance
endfunction

call g:project_lint#linters.add(s:instance)
