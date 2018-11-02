let s:govet = {}

function! s:govet.New() abort
  let l:instance = copy(self)
  let l:instance.name = 'govet'
  let l:instance.cmd = ''
  let l:instance.cmd_args = get(g:defx_lint#linter_args, 'govet', '')
  let l:instance.stream = 'stderr'
  let l:instance.filetype = ['go']
  return l:instance
endfunction

function! s:govet.Detect() abort
  return len(defx_lint#utils#find_extension('go')) > 0 && self.Executable()
endfunction

function! s:govet.DetectForFile() abort
  return index(self.filetype, &filetype) > -1
endfunction

function! s:govet.Executable() abort
  if executable('go')
    let self.cmd = 'go vet'
    return v:true
  endif

  return v:false
endfunction

function! s:govet.Cmd() abort
  if self.cmd ==? ''
    return ''
  endif

  return printf('%s %s .', self.cmd, self.cmd_args)
endfunction

function! s:govet.FileCmd(file) abort
  if self.cmd ==? ''
    return ''
  endif

  return printf('%s %s %s', self.cmd, self.cmd_args, a:file)
endfunction

function! s:govet.Parse(item) abort
  return defx_lint#utils#parse_unix(a:item, v:true)
endfunction

call defx_lint#add_linter(s:govet.New())
