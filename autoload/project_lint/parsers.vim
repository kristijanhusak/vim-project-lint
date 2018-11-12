function! project_lint#parsers#unix(item) abort
  let l:pattern = '^\(\/\?[^:]*\):\d*.*$'
  if empty(a:item) || a:item !~? l:pattern
    return ''
  endif

  let l:list = matchlist(a:item, l:pattern)

  if len(l:list) < 2 || empty(l:list[1])
    return ''
  endif

  let l:item = l:list[1]

  if stridx(l:item, g:project_lint#root) > -1
    return l:item
  endif

  return printf('%s/%s', g:project_lint#root, l:item)
endfunction

function! project_lint#parsers#unix_with_severity(item, severity_pattern, severity_text, ...) abort
  let l:check_error_severity_first = a:0 > 0
  let l:file = project_lint#parsers#unix(a:item)
  if empty(l:file)
    return {}
  endif

  let l:matches = matchlist(a:item, a:severity_pattern)
  let l:severity = get(l:matches, 1, '')

  let l:severity_text = 'w'
  let l:fallback_severity_text = 'e'

  if l:check_error_severity_first
    let l:severity_text = 'e'
    let l:fallback_severity_text = 'w'
  endif

  if l:severity ==? a:severity_text
    return {'path': l:file, 'severity': l:severity_text }
  endif

  return {'path': l:file, 'severity': l:fallback_severity_text }
endfunction
