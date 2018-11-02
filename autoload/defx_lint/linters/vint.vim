let s:vint = copy(defx_lint#linters#base#get())
let s:vint.name = 'vint'
let s:vint.filetype = ['vim']

function! s:vint.detect() abort
  return !empty(self.cmd) && len(defx_lint#utils#find_extension('vim')) > 0
endfunction

function! s:vint.executable() abort
  if executable('vint')
    return 'vint'
  endif

  return ''
endfunction

call defx_lint#add_linter(s:vint.new())
