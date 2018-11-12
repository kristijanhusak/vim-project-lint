let s:ruby = copy(project_lint#base_linter#get())
let s:ruby.name = 'ruby'
let s:ruby.stream = 'stderr'
let s:ruby.filetype = ['ruby']
let s:ruby.cmd_args = '-w -c -T1'

function! s:ruby.check_executable() abort
  if executable('ruby')
    return self.set_cmd('ruby')
  endif

  return self.set_cmd('')
endfunction

function! s:ruby.command() abort
  return project_lint#utils#xargs_lint_command('rb', self.cmd, self.cmd_args)
endfunction

function! s:ruby.parse(item) abort
  let l:path = project_lint#utils#parse_unix(a:item)
  if empty(l:path)
    return {}
  endif

  let l:pattern = '^[^:]*:\d*: \(warning\)\?.*$'
  let l:matches = matchlist(a:item, l:pattern)
  echom string(l:matches)

  if len(l:matches) < 2
    return {}
  endif

  if l:matches[1] ==? 'warning'
    return self.warning(l:path)
  endif

  return self.error(l:path)
endfunction

call project_lint#linters.add(s:ruby.new())
