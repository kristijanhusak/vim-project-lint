let s:eslint = copy(project_lint#base_linter#get())
let s:eslint.name = 'eslint'
let s:eslint.filetype = ['javascript', 'javascript.jsx']

function! s:eslint.check_executable() abort
  let l:local = printf('%s/node_modules/.bin/eslint', g:project_lint#root)
  let l:global = 'eslint'
  if executable(l:local)
    return self.set_cmd(l:local)
  endif

  if executable(l:global)
    return self.set_cmd(l:global)
  endif

  return self.set_cmd('')
endfunction

function! s:eslint.command() abort
  return printf('%s --format=unix %s .', self.cmd, self.cmd_args)
endfunction

function! s:eslint.file_command(file) abort
  return printf('%s --format=unix %s %s', self.cmd, self.cmd_args, a:file)
endfunction

call g:project_lint#linters.add(s:eslint.new())
