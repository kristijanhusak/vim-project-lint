function! project_lint#utils#echo_line(text) abort
  silent! exe 'redraw'
  echom a:text
endfunction

let s:statusline = ''

function! project_lint#utils#get_statusline() abort
  return s:statusline
endfunction

function! project_lint#utils#set_statusline() abort
  let l:running_linters = g:project_lint#queue.get_running_linters()
  if empty(l:running_linters.project) && empty(l:running_linters.files)
    let s:statusline = ''
    return v:false
  endif

  let l:text = []

  if len(l:running_linters.project) > 0
    call add(l:text, printf('project with: %s', l:running_linters.project))
  endif

  if len(l:running_linters.files) > 0
    call add(l:text, printf('file(s) with: %s', l:running_linters.files))
  endif

  let l:text = join(l:text, ', ')

  let l:cache_text = g:project_lint#data.use_cache ? 'Loaded from cache. Refreshing': 'Linting'
  let s:statusline = printf('%s %s', l:cache_text, l:text)
endfunction

function! project_lint#utils#parse_unix(item) abort
  if matchstr(a:item, ':') ==? ''
    return ''
  endif

  let l:items = split(a:item, ':')
  if len(l:items) <=? 0
    return ''
  endif

  if stridx(l:items[0], getcwd()) > -1
    return l:items[0]
  endif

  return printf('%s/%s', getcwd(), l:items[0])
endfunction

let s:extensions_found = {}
function! project_lint#utils#find_extension(extension) abort
  if has_key(s:extensions_found, a:extension)
    return s:extensions_found[a:extension]
  endif
  let l:items = s:find_extension(a:extension)
  if len(l:items) > 0
    let s:extensions_found[a:extension] = l:items[0]
    return l:items[0]
  endif

  return ''
endfunction

function! project_lint#utils#has_file_in_cwd(file) abort
  return filereadable(printf('%s/%s', getcwd(), a:file))
endfunction

function! project_lint#utils#debug(msg) abort
  if !get(g:, 'project_lint#debug', v:false)
    return
  endif

  return project_lint#utils#echo_line(a:msg)
endfunction

function s:find_extension(extension) abort
  if executable('rg')
    return systemlist(printf("rg --files --glob '**/*.%s'", a:extension))
  endif

  if executable('ag')
    return systemlist(printf('ag -g "^.*\.%s$"', a:extension))
  endif

  return glob(printf('**/*.%s', a:extension), v:false, v:true)
endfunction
