let s:statusline = ''

function! project_lint#utils#update_statusline() abort
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

function! project_lint#utils#get_statusline() abort
  return s:statusline
endfunction

function! project_lint#utils#echo_line(text) abort
  silent! exe 'redraw'
  echom a:text
endfunction

function! project_lint#utils#error(text) abort
  echohl Error
  call project_lint#utils#echo_line(a:text)
  echohl NONE
endfunction

function! project_lint#utils#parse_unix(item) abort
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
  return filereadable(printf('%s/%s', g:project_lint#root, a:file))
endfunction

function! project_lint#utils#debug(msg) abort
  if !get(g:, 'project_lint#debug', v:false)
    return
  endif

  return project_lint#utils#echo_line(a:msg)
endfunction

function! project_lint#utils#find_extension_cmd(extension) abort
  if executable('rg')
    return printf("rg --files -g '*.%s' %s", a:extension, g:project_lint#root)
  endif

  if executable('ag')
    return printf('ag -g "^.*\.%s$" %s', a:extension, g:project_lint#root)
  endif

  if executable('find')
    return printf('find %s -name "*.%s"', g:project_lint#root, a:extension)
  endif

  return ''
endfunction

function! s:find_extension(extension) abort
  let l:cmd = project_lint#utils#find_extension_cmd(a:extension)
  if !empty(l:cmd)
    return project_lint#utils#system(l:cmd)
  endif

  return glob(printf('%s/**/*.%s', g:project_lint#root, a:extension), v:false, v:true)
endfunction

function! project_lint#utils#get_project_root() abort
  let l:project_file = findfile('.vimprojectlint', printf('%s;', getcwd()))
  if !empty(l:project_file)
    let l:project_file = fnamemodify(l:project_file, ':p:h')
  endif
  let l:git_root = ''
  if executable('git')
    let l:cmd = systemlist('git rev-parse --show-toplevel')
    if !v:shell_error
      let l:git_root = fnamemodify(l:cmd[0], ':p:h')
    endif
  endif

  if empty(l:project_file) && empty(l:git_root)
    return getcwd()
  endif

  if len(l:project_file) > len(l:git_root)
    return l:project_file
  endif

  return l:git_root
endfunction

function! project_lint#utils#system(cmd) abort
  let l:save_shell = s:set_shell()
  let l:cmd_output = systemlist(a:cmd)
  call s:restore_shell(l:save_shell)
  return l:cmd_output
endfunction

function! s:set_shell() abort
  let l:save_shell = [&shell, &shellcmdflag, &shellredir]

  if has('win32')
    set shell=cmd.exe shellcmdflag=/c shellredir=>%s\ 2>&1
  else
    set shell=sh shellredir=>%s\ 2>&1
  endif

  return l:save_shell
endfunction

function! s:restore_shell(saved_shell) abort
  let [&shell, &shellcmdflag, &shellredir] = a:saved_shell
endfunction

function! project_lint#utils#xargs_lint_command(extension, cmd, cmd_args) abort
  let l:ext_cmd = project_lint#utils#find_extension_cmd(a:extension)
  return printf('%s | xargs -L 1 %s %s', l:ext_cmd,  a:cmd, a:cmd_args)
endfunction

function! project_lint#utils#get_nested_key(dict, key, ...) abort
  let l:items = split(a:key, '\.')
  let l:result = get(a:dict, l:items[0], {})
  let l:default = a:0 > 0 ? a:1 : {}
  if empty(l:result)
    return l:default
  endif

  for l:item in l:items[1:]
    if type(l:result) !=? type({})
      return l:default
    endif

    let l:result = get(l:result, l:item, {})
    if empty(l:result)
      return l:default
    endif
  endfor

  return l:result
endfunction
