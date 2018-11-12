let s:luac = copy(project_lint#base_linter#get())
let s:luac.name = 'luac'
let s:luac.stream = 'stderr'
let s:luac.filetype = ['lua']
let s:luac.cmd_args = '-p'

function! s:luac.check_executable() abort
  if executable('luac')
    return self.set_cmd('luac')
  endif

  return self.set_cmd('')
endfunction

function! s:luac.command() abort
  return printf('%s %s %s/**/*.lua', self.cmd, self.cmd_args, g:project_lint#root)
endfunction

function! s:luac.parse(item) abort
  let l:path = project_lint#parsers#unix(substitute(a:item, '^luac:\s', '', ''))
  if empty(l:path)
    return {}
  endif

  return self.error(l:path)
endfunction

call g:project_lint#linters.add(s:luac.new())
