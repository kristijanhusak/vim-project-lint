let s:vint = copy(project_lint#base_linter#get())
let s:vint.name = 'vint'
let s:vint.filetype = ['vim']
let s:vint.cmd_args = printf('-w -f "{file_path}:{severity}" %s', has('nvim') ? ' --enable-neovim' : '')

function! s:vint.check_executable() abort
  if executable('vint')
    return self.set_cmd('vint')
  endif

  return self.set_cmd('')
endfunction

function! s:vint.parse(item) abort
  let l:pattern = '^\([^:]*\):\(.\).*$'
  if a:item !~? l:pattern
    return {}
  endif
  let l:matches = matchlist(a:item, l:pattern)
  if len(l:matches) < 3 || empty(l:matches[1])
    return {}
  endif

  return { 'path': l:matches[1], 'type': l:matches[2] }
endfunction

call g:project_lint#linters.add(s:vint.new())
