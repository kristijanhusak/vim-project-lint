let s:base = {}

function! project_lint#linters#base#get() abort
  return s:base
endfunction

function! s:base.new() abort
  let l:instance = copy(self)
  let l:instance.name = get(l:instance, 'name', '')
  let l:instance.cmd = l:instance.executable()
  let l:cmd_args = get(self, 'cmd_args', '')
  let l:instance.cmd_args = get(g:project_lint#linter_args, l:instance.name, l:cmd_args)
  let l:instance.stream = get(l:instance, 'stream', 'stdout')
  let l:instance.filetype = get(l:instance, 'filetype', [])
  return l:instance
endfunction

function! s:base.detect() abort
  return !empty(self.cmd)
endfunction

function! s:base.detect_for_file() abort
  return !empty(self.cmd) && index(self.filetype, &filetype) > -1
endfunction

function! s:base.executable() abort
  return ''
endfunction

function! s:base.command() abort
  return printf('%s %s .', self.cmd, self.cmd_args)
endfunction

function! s:base.file_command(file) abort
  return printf('%s %s %s', self.cmd, self.cmd_args, a:file)
endfunction

function! s:base.parse(item) abort
  return project_lint#utils#parse_unix(a:item)
endfunction
