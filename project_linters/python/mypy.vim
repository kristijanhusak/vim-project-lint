let s:mypy = copy(project_lint#base_linter#get())
let s:mypy.name = 'mypy'
let s:mypy.filetype = ['python']
let s:mypy.dir = ''

function! s:mypy.detect() abort
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

function! s:mypy.executable() abort
  if executable('mypy')
    return 'mypy'
  endif

  return ''
endfunction

function! s:mypy.command() abort
  let l:target = '.'
  if !empty(self.dir)
    let l:target = self.dir
  endif

  return printf('%s %s %s', self.cmd, self.cmd_args, l:target)
endfunction

call g:project_lint#linters.add(s:mypy.new())
