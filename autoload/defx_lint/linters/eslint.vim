let s:eslint = {}

function! s:eslint.new() abort
  let l:instance = copy(self)
  let l:instance.name = 'eslint'
  let l:instance.cmd = l:instance.executable()
  let l:instance.cmd_args = get(g:defx_lint#linter_args, 'eslint', '')
  let l:instance.stream = 'stdout'
  let l:instance.filetype = ['javascript', 'javascript.jsx']
  return l:instance
endfunction

function! s:eslint.detect() abort
  return !empty(self.cmd) && filereadable(printf('%s/package.json', getcwd()))
endfunction

function! s:eslint.detect_for_file() abort
  return !empty(self.cmd) && index(self.filetype, &filetype) > -1
endfunction

function! s:eslint.executable() abort
  let l:local = printf('%s/node_modules/.bin/eslint', getcwd())
  let l:global = 'eslint'
  if executable(l:local)
    return l:local
  endif

  if executable(l:global)
    return l:global
  endif

  return ''
endfunction

function! s:eslint.command() abort
  return printf('%s --format=unix %s .', self.cmd, self.cmd_args)
endfunction

function! s:eslint.file_command(file) abort
  return printf('%s --format=unix %s %s', self.cmd, self.cmd_args, a:file)
endfunction

function! s:eslint.parse(item) abort
  return defx_lint#utils#parse_unix(a:item)
endfunction

call defx_lint#add_linter(s:eslint.new())
