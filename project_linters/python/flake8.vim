let s:flake8 = copy(project_lint#base_linter#get())
let s:flake8.name = 'flake8'
let s:flake8.filetype = ['python']

function! s:flake8.executable() abort
  if executable('flake8')
    return 'flake8'
  endif

  return ''
endfunction

call g:project_lint#linters.add(s:flake8.new())
