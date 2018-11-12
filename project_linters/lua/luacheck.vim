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
  let l:file = project_lint#utils#parse_unix(a:item)
  if empty(l:file)
    return {}
  endif

  let l:pattern = '^.*:\d\+:\d\+: (\([WE]\)\d\+) .\+$'
  let l:matches = matchlist(a:item, l:pattern)
  if len(l:matches) >= 2 && !empty(l:matches[1]) && l:matches[1] ==? 'W'
    return self.warning(l:file)
  endif

  return self.error(l:file)
endfunction

call g:project_lint#linters.add(s:luacheck.new())
