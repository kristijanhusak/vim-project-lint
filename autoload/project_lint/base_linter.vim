let s:base = {}

function! project_lint#base_linter#get() abort
  return s:base
endfunction

function! s:base.new() abort
  let l:instance = copy(self)
  let l:instance.name = get(l:instance, 'name', '')
  let l:cmd_args = get(self, 'cmd_args', '')
  let l:user_args = get(g:project_lint#linter_args, l:instance.name, '')
  let l:instance.cmd_args = join(filter([l:cmd_args, l:user_args], 'v:val !=? ""'), ' ')
  let l:instance.stream = get(l:instance, 'stream', 'stdout')
  let l:instance.filetype = get(l:instance, 'filetype', [])
  let l:instance.format = get(l:instance, 'format', 'unix')
  let l:instance.enabled_filetype = g:project_lint#linters.get_enabled_filetypes(l:instance)
  call l:instance.check_executable()
  return l:instance
endfunction

function! s:base.detect() abort
  return !empty(self.cmd) && !empty(self.enabled_filetype)
endfunction

function! s:base.detect_for_file() abort
  return !empty(self.cmd) && index(self.enabled_filetype, &filetype) > -1
endfunction

function! s:base.check_executable() abort
  return self.set_cmd('')
endfunction

function! s:base.command() abort
  return printf('%s %s %s', self.cmd, self.cmd_args, g:project_lint#root)
endfunction

function! s:base.file_command(file) abort
  return printf('%s %s %s', self.cmd, self.cmd_args, a:file)
endfunction

function! s:base.parse(item) abort
  let l:path = project_lint#parsers#unix(a:item)
  if empty(l:path)
    return {}
  endif

  return self.error(l:path)
endfunction

function! s:base.set_cmd(cmd) abort
  let self.cmd = a:cmd
  return !empty(self.cmd)
endfunction

function! s:base.error(path) abort
  return { 'path': a:path, 'severity': 'e' }
endfunction

function! s:base.warning(path) abort
  return { 'path': a:path, 'severity': 'w' }
endfunction

function! s:base.parse_messages(messages) abort
  let l:msg = a:messages

  if self.format ==? 'json' && !empty(a:messages[0])
    try
      let l:msg = json_decode(a:messages[0])
    catch
      return []
    endtry

    if type(l:msg) !=? type([])
      return []
    endif
  endif

  return l:msg
endfunction
