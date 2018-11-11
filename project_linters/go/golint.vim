let s:golint = copy(project_lint#base_linter#get())
let s:golint.name = 'golint'
let s:golint.filetype = ['go']

function! s:golint.check_executable() abort
  if executable('golint')
    return self.set_cmd('golint')
  endif

  return self.set_cmd('')
endfunction

function! s:golint.command() abort
  return printf('%s %s %s/...', self.cmd, self.cmd_args, g:project_lint#root)
endfunction

call g:project_lint#linters.add(s:golint.new())
