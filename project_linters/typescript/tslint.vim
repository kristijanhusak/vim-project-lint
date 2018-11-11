let s:tslint = copy(project_lint#base_linter#get())
let s:tslint.name = 'tslint'
let s:tslint.filetype = ['typescript']
let s:tslint.cmd_args = '--outputAbsolutePaths --format msbuild'

function! s:tslint.check_executable() abort
  let l:local = printf('%s/node_modules/.bin/tslint', g:project_lint#root)
  let l:global = 'tslint'
  if filereadable(printf('%s/tslint.json', g:project_lint#root)) && self.cmd_args !~? 'tslint.json'
    let self.cmd_args .= ' -c tslint.json'
  endif

  if executable(l:local)
    return self.set_cmd(l:local)
  endif

  if executable(l:global)
    return self.set_cmd(l:global)
  endif

  return self.set_cmd('')
endfunction

function! s:tslint.command() abort
  let l:ext_cmd = project_lint#utils#find_extension_cmd('ts')
  return printf('%s | grep -v node_modules | xargs %s %s', l:ext_cmd, self.cmd, self.cmd_args)
endfunction

function! s:tslint.parse(item) abort
  let l:pattern = '^\(\/[^(]*\)([^)]*).*$'

  if empty(a:item) || a:item !~? l:pattern
    return ''
  endif

  let l:list = matchlist(a:item, l:pattern)

  if len(l:list) < 2 || empty(l:list[1])
    return ''
  endif

  return l:list[1]
endfunction

call g:project_lint#linters.add(s:tslint.new())
