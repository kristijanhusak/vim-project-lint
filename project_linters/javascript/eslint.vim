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
  return project_lint#parsers#unix_with_severity(
        \ a:item,
        \ '^.*\s\[\(Warning\|Error\)\/[^\]]*\]$',
        \ 'Warning'
        \ )
endfunction

let s:instance = s:eslint.new()

function project_linters#javascript#eslint#get() abort
  return s:instance
endfunction

call g:project_lint#linters.add(s:instance)
