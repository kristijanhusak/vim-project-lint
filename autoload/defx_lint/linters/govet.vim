let s:govet = {}

function! s:govet.New() abort
  let l:instance = copy(self)
  let l:instance.name = 'govet'
  let l:instance.cmd = ''
  let l:instance.stream = 'stderr'
  let l:instance.filetype = ['go']
  return l:instance
endfunction

function! s:govet.Detect() abort
  return len(glob('**/*.go', v:false, v:true)) > 0 && self.Executable() !=? ''
endfunction

function! s:govet.DetectForFile() abort
  return index(self.filetype, &filetype) > -1
endfunction

function! s:govet.Executable() abort
  if executable('go')
    let self.cmd = 'go vet'
    return 'go vet'
  endif

  return ''
endfunction

function! s:govet.Cmd() abort
  if self.cmd ==? ''
    return ''
  endif

  return printf('%s .', self.cmd)
endfunction

function! s:govet.FileCmd(file) abort
  if self.cmd ==? ''
    return ''
  endif

  return printf('%s %s', self.cmd, a:file)
endfunction

function! s:govet.Parse(item) abort
  if matchstr(a:item, ':') ==? ''
    return ''
  endif

  let l:items = split(a:item, ':')
  if len(l:items) > 0
    return printf('%s/%s', getcwd(), l:items[0])
  endif

  return ''
endfunction

call defx_lint#add_linter(s:govet.New())
