let s:flake8 = copy(project_lint#base_linter#get())
let s:flake8.name = 'flake8'
let s:flake8.filetype = ['python']

function! s:flake8.check_executable() abort
  if executable('flake8')
    return self.set_cmd('flake8')
  endif

  return self.set_cmd('')
endfunction

function! s:flake8.parse(item) abort
  let l:file = project_lint#utils#parse_unix(a:item)
  if empty(l:file)
    return {}
  endif
  let l:pattern = '^[^:]*:\d\+:\d\+: \(.\).*$'
  let l:matches = matchlist(a:item, l:pattern)

  if len(l:matches) >= 2 && l:matches[1] ==? 'W'
    return self.warning(l:file)
  endif

  return self.error(l:file)
endfunction

call g:project_lint#linters.add(s:flake8.new())
