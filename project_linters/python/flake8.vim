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
  return project_lint#parsers#unix_with_severity(
        \ a:item,
        \ '^[^:]*:\d\+:\d\+: \(.\).*$',
        \ 'W'
        \ )
endfunction

call g:project_lint#linters.add(s:flake8.new())
