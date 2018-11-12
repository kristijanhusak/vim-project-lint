let s:php = copy(project_lint#base_linter#get())
let s:php.name = 'php'
let s:php.stream = 'stderr'
let s:php.filetype = ['php']
let s:php.cmd_args = '-l'

function! s:php.check_executable() abort
  if executable('php')
    return self.set_cmd('php')
  endif

  return self.set_cmd('')
endfunction

function! s:php.command() abort
  return project_lint#utils#xargs_lint_command('php', self.cmd, self.cmd_args)
endfunction

function! s:php.parse(item) abort
  let l:pattern = '\v^.*(Parse|Fatal) error:.*in (.*\.php) on.*$'

  if a:item !~? l:pattern
    return {}
  endif

  let l:matches = matchlist(a:item, l:pattern)


  if len(l:matches) < 3 || empty(l:matches[2])
    return {}
  endif

  if stridx(l:matches[2], g:project_lint#root) > -1
    return self.error(l:matches[2])
  endif

  return self.error(printf('%s/%s', g:project_lint#root, l:matches[2]))
endfunction

call g:project_lint#linters.add(s:php.new())
