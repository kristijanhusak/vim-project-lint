let s:flake8 = copy(project_lint#linters#base#get())
let s:flake8.name = 'flake8'
let s:flake8.filetype = ['python']
let s:flake8.dir = ''

function! s:flake8.detect() abort
  if empty(self.cmd)
    return v:false
  endif
  let l:file = project_lint#utils#find_extension('py')
  if empty(l:file)
    return v:false
  endif

  let self.dir = fnamemodify(l:file, ':p:h')
  return v:true
endfunction

function! s:flake8.executable() abort
  if executable('flake8')
    return 'flake8'
  endif

  return ''
endfunction

call project_lint#add_linter(s:flake8.new())
