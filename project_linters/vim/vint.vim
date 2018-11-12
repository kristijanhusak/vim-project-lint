let s:vint = copy(project_lint#base_linter#get())
let s:vint.name = 'vint'
let s:vint.filetype = ['vim']
let s:vint.cmd_args = printf('-w -f "{file_path}:{line_number}:{severity}" %s', has('nvim') ? ' --enable-neovim' : '')

function! s:vint.check_executable() abort
  if executable('vint')
    return self.set_cmd('vint')
  endif

  return self.set_cmd('')
endfunction

function! s:vint.parse(item) abort
  return project_lint#parsers#unix_with_severity(
        \ a:item,
        \ '^[^:]*:\d*:\(.*\)$',
        \ 'warning'
        \ )
endfunction

call g:project_lint#linters.add(s:vint.new())
