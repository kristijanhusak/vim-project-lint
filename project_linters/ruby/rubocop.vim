let s:rubocop = copy(project_lint#base_linter#get())
let s:rubocop.name = 'rubocop'
let s:rubocop.filetype = ['ruby']
let s:rubocop.cmd_args = '--no-color -l --format fi'

function! s:rubocop.check_executable() abort
  if executable('rubocop')
    return self.set_cmd('rubocop')
  endif

  return self.set_cmd('')
endfunction

function! s:rubocop.parse(item) abort
  if a:item =~? '^\/.*\.rb$'
    return self.error(a:item)
  endif

  return {}
endfunction

call g:project_lint#linters.add(s:rubocop.new())
