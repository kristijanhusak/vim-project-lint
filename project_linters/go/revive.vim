let s:revive = copy(project_lint#base_linter#get())
let s:revive.name = 'revive'
let s:revive.filetype = ['go']

function! s:revive.check_executable() abort
  if executable('revive')
    return self.set_cmd('revive')
  endif

  return self.set_cmd('')
endfunction

function! s:revive.command() abort
  return printf('%s %s %s/...', self.cmd, self.cmd_args, g:project_lint#root)
endfunction

call g:project_lint#linters.add(s:revive.new())
