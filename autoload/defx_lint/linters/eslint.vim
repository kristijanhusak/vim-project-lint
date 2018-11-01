let s:eslint = {}

function! s:eslint.New() abort
  let l:instance = copy(self)
  let l:instance.name = 'eslint'
  let l:instance.cmd = ''
  let l:instance.cmd_args = get(g:, 'defx_lint#linter_args.eslint', '')
  let l:instance.stream = 'stdout'
  let l:instance.filetype = ['javascript', 'javascript.jsx']
  return l:instance
endfunction

function! s:eslint.Detect() abort
  return filereadable(printf('%s/package.json', getcwd())) && self.Executable()
endfunction

function! s:eslint.DetectForFile() abort
  return index(self.filetype, &filetype) > -1
endfunction

function! s:eslint.Executable() abort
  let l:local = printf('%s/node_modules/.bin/eslint', getcwd())
  let l:global = 'eslint'
  if executable(l:local)
    let self.cmd = l:local
    return v:true
  endif

  if executable(l:global)
    let self.cmd = l:global
    return v:true
  endif

  return v:false
endfunction

function! s:eslint.Cmd() abort
  if self.cmd ==? ''
    return ''
  endif

  return printf('%s --format=unix %s .', self.cmd, self.cmd_args)
endfunction

function! s:eslint.FileCmd(file) abort
  if self.cmd ==? ''
    return ''
  endif

  return printf('%s --format=unix %s', self.cmd, a:file)
endfunction

function! s:eslint.Parse(item) abort
  return defx_lint#utils#parse_unix(a:item)
endfunction

call defx_lint#add_linter(s:eslint.New())
