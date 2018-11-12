let s:rubocop = copy(project_lint#base_linter#get())
let s:rubocop.name = 'rubocop'
let s:rubocop.filetype = ['ruby']
let s:rubocop.cmd_args = '--no-color -l --format json'

function! s:rubocop.check_executable() abort
  if executable('rubocop')
    return self.set_cmd('rubocop')
  endif

  return self.set_cmd('')
endfunction

function! s:rubocop.parse(item) abort
  let l:has_error = v:false
  let l:warnings = ['convention', 'warning', 'refactor']

  for l:offense in a:item.offenses
    if index(l:warnings, l:offense.severity) < 0
      let l:has_error = v:true
    endif
  endfor

  let l:path = printf('%s/%s', g:project_lint#root, a:item.path)

  if l:has_error
    return self.error(l:path)
  endif

  return self.warning(l:path)
endfunction

function! s:rubocop.parse_messages(messages) abort
  if empty(a:messages[0])
    return []
  endif

  try
    let l:data = json_decode(a:messages[0])
  catch
    return []
  endtry

  if type(l:data) !=? type({})
    return []
  endif

  return get(l:data, 'files', [])
endfunction

call g:project_lint#linters.add(s:rubocop.new())
