let s:govet = {}

function! s:govet.new() abort
  let l:instance = copy(self)
  let l:instance.name = 'govet'
  let l:instance.cmd = l:instance.executable()
  let l:instance.cmd_args = get(g:defx_lint#linter_args, 'govet', '')
  let l:instance.stream = 'stderr'
  let l:instance.filetype = ['go']
  return l:instance
endfunction

function! s:govet.detect() abort
  return !empty(self.cmd) && len(defx_lint#utils#find_extension('go')) > 0 && self.executable()
endfunction

function! s:govet.detect_for_file() abort
  return !empty(self.cmd) && index(self.filetype, &filetype) > -1
endfunction

function! s:govet.executable() abort
  if executable('go')
    return 'go vet'
  endif

  return ''
endfunction

function! s:govet.command() abort
  return printf('%s %s .', self.cmd, self.cmd_args)
endfunction

function! s:govet.file_command(file) abort
  return printf('%s %s %s', self.cmd, self.cmd_args, a:file)
endfunction

function! s:govet.parse(item) abort
  return defx_lint#utils#parse_unix(a:item, v:true)
endfunction

call defx_lint#add_linter(s:govet.new())
