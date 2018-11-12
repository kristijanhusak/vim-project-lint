let s:eslint = copy(project_lint#base_linter#get())
let s:eslint.name = 'eslint'
let s:eslint.filetype = ['javascript', 'javascript.jsx', 'typescript']
let s:eslint.cmd_args = '--format=unix'

function! s:eslint.check_executable() abort
  let l:local = printf('%s/node_modules/.bin/eslint', g:project_lint#root)
  let l:global = 'eslint'
  if executable(l:local)
    return self.set_cmd(l:local)
  endif

  if executable(l:global)
    return self.set_cmd(l:global)
  endif

  return self.set_cmd('')
endfunction

function! s:eslint.parse(item) abort
  let l:path = project_lint#utils#parse_unix(a:item)
  if empty(l:path)
    return {}
  endif

  let l:type_pattern = '^.*\s\[\(Warning\|Error\)\/[^\]]*\]$'
  let l:matches = matchlist(a:item, l:type_pattern)

  if len(l:matches) > 1 && !empty(l:matches[1]) && l:matches[1] ==? 'Warning'
    return self.warning(l:path)
  endif

  return self.error(l:path)
endfunction

let s:instance = s:eslint.new()

function project_linters#javascript#eslint#get() abort
  return s:instance
endfunction

call g:project_lint#linters.add(s:instance)
