let s:eslint = {}

function! s:eslint.New() abort
  let l:instance = copy(self)
  let l:instance.name = 'eslint'
  let l:instance.cmd = ''
  let l:instance.stream = 'stdout'
  let l:instance.filetype = ['javascript', 'javascript.jsx']
  return l:instance
endfunction

function! s:eslint.Detect() abort
  return filereadable(printf('%s/package.json', getcwd())) && self.Executable() !=? ''
endfunction

function! s:eslint.DetectForFile() abort
  return index(self.filetype, &filetype) > -1
endfunction

function! s:eslint.Executable() abort
  let l:local = printf('%s/node_modules/.bin/eslint', getcwd())
  let l:global = 'eslint'
  if executable(l:local)
    let self.cmd = l:local
    return l:local
  endif

  if executable(l:global)
    let self.cmd = l:global
    return l:global
  endif

  return ''
endfunction

function! s:eslint.Cmd() abort
  if self.cmd ==? ''
    return ''
  endif

  return printf('%s --format=unix .', self.cmd)
endfunction

function! s:eslint.FileCmd(file) abort
  if self.cmd ==? ''
    return ''
  endif

  return printf('%s --format=unix %s', self.cmd, a:file)
endfunction

function! s:eslint.Parse(item) abort
  if matchstr(a:item, ':') ==? ''
    return ''
  endif

  let l:items = split(a:item, ':')
  if len(l:items) > 0
    return l:items[0]
  endif

  return ''
endfunction

call defx_lint#add_linter(s:eslint.New())
