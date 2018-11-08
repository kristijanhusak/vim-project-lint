let s:vint = copy(project_lint#base_linter#get())
let s:vint.name = 'vint'
let s:vint.filetype = ['vim']
let s.vint.cmd_args = printf('-w%s', has('nvim') ? ' --enable-neovim' : '')

function! s:vint.check_executable() abort
  if executable('vint')
    return self.set_cmd('vint')
  endif

  return self.set_cmd('')
endfunction

call g:project_lint#linters.add(s:vint.new())
