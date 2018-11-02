let s:mypy = copy(defx_lint#linters#base#get())
let s:mypy.name = 'mypy'
let s:mypy.filetype = ['python']
let s:mypy.files = []

function! s:mypy.detect() abort
  if empty(self.cmd)
    return v:false
  endif
  let self.files = defx_lint#utils#find_extension('py')
  return len(self.files) > 0
endfunction

function! s:mypy.executable() abort
  if executable('mypy')
    return 'mypy'
  endif

  return ''
endfunction

function! s:mypy.command() abort
  let l:target = '.'
  if len(self.files) > 0
    let l:target = fnamemodify(self.files[0], ':p:h')
  endif

  return printf('%s %s %s', self.cmd, self.cmd_args, l:target)
endfunction

call defx_lint#add_linter(s:mypy.new())
