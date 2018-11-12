let s:mypy = copy(project_lint#base_linter#get())
let s:mypy.name = 'mypy'
let s:mypy.filetype = ['python']

function! s:mypy.detect() abort
  return !empty(self.cmd) && !empty(project_lint#utils#find_extension('py'))
endfunction

function! s:mypy.check_executable() abort
  if executable('mypy')
    return self.set_cmd('mypy')
  endif

  return self.set_cmd('')
endfunction

function! s:mypy.command() abort
  return printf('%s %s %s/**/*.py', self.cmd, self.cmd_args, g:project_lint#root)
endfunction

function! s:mypy.parse(item) abort
  let l:file = project_lint#utils#parse_unix(a:item)
  if empty(l:file)
    return {}
  endif

  let l:pattern = '^[^:]*:\d\+:\d\+: \(error|warning\): .\+$'
  let l:matches = matchlist(a:item, l:pattern)

  if len(l:matches) >= 2 && l:matches[1] ==? 'error'
    return self.error(l:file)
  endif

  return self.warning(l:file)
endfunction

call g:project_lint#linters.add(s:mypy.new())
