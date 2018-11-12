let s:luacheck = copy(project_lint#base_linter#get())
let s:luacheck.name = 'luacheck'
let s:luacheck.filetype = ['lua']
let s:luacheck.cmd_args = '--formatter plain --codes --no-color'

function! s:luacheck.check_executable() abort
  if executable('luacheck')
    return self.set_cmd('luacheck')
  endif

  return self.set_cmd('')
endfunction

function! s:luacheck.parse(item) abort
  return project_lint#parsers#unix_with_severity(
        \ a:item,
        \ '^.*:\d\+:\d\+: (\([WE]\)\d\+) .\+$',
        \ 'W'
        \ )
endfunction

call g:project_lint#linters.add(s:luacheck.new())
