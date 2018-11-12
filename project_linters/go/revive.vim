let s:revive = copy(project_lint#base_linter#get())
let s:revive.name = 'revive'
let s:revive.filetype = ['go']
let s:revive.cmd_args = '-formatter json'
let s:revive.format = 'json'

function! s:revive.check_executable() abort
  if executable('revive')
    return self.set_cmd('revive')
  endif

  return self.set_cmd('')
endfunction

function! s:revive.command() abort
  return printf('%s %s %s/...', self.cmd, self.cmd_args, g:project_lint#root)
endfunction

function! s:revive.parse(item) abort
  if empty(a:item) || type(a:item) !=? type({})
    return {}
  endif


  let l:type = get(a:item, 'Severity', 'error')
  let l:file = project_lint#utils#get_nested_key(a:item, 'Position.Start.Filename')

  if empty(l:file)
    return {}
  endif

  if l:type ==? 'warning'
    return self.warning(l:file)
  endif

  return self.error(l:file)
endfunction

call g:project_lint#linters.add(s:revive.new())
