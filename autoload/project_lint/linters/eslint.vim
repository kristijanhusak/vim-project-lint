let s:eslint = copy(project_lint#linters#base#get())
let s:eslint.name = 'eslint'
let s:eslint.filetype = ['javascript', 'javascript.jsx']

function! s:eslint.detect() abort
  return !empty(self.cmd) && filereadable(printf('%s/package.json', getcwd()))
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

call project_lint#add_linter(s:eslint.new())