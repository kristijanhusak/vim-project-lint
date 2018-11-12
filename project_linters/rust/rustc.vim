let s:rustc = copy(project_lint#base_linter#get())
let s:rustc.name = 'rustc'
let s:rustc.stream = 'stderr'
let s:rustc.filetype = ['rust']
let s:rustc.cmd_args = '--color never --error-format short'

function! s:rustc.check_executable() abort
  if executable('rustc')
    return self.set_cmd('rustc')
  endif

  return self.set_cmd('')
endfunction

function! s:rustc.command() abort
  return project_lint#utils#xargs_lint_command('rs', self.cmd, self.cmd_args)
endfunction

function! s:rustc.parse(item) abort
  let l:file = project_lint#utils#parse_unix(a:item)
  if empty(l:file)
    return {}
  endif

  let l:pattern = '^[^:]*:\d*:\d*: \(error\|warning\).*$'

  let l:matches = matchlist(a:item, l:pattern)

  if len(l:matches) >= 2 && l:matches[1] ==? 'warning'
    return self.warning(l:file)
  endif

  return self.error(l:file)
endfunction

call g:project_lint#linters.add(s:rustc.new())
