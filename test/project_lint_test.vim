let s:suite = themis#suite('project_lint')
let s:assert = themis#helper('assert')
let s:scope =  themis#helper('scope')
let s:mock_functions = s:scope.funcs('test/linter_mock.vim')
let s:linter_mock = s:mock_functions.get_mock()
let s:file_mock = s:mock_functions.get_mock_file()

let s:job = project_lint#job#new()
let s:linters = project_lint#linters#new()
call s:linters.add(s:linter_mock)
let s:data = project_lint#data#new()
let s:queue = project_lint#queue#new(s:job, s:data)
let s:file_explorers = project_lint#file_explorers#new()

let s:project_lint = project_lint#new(s:linters, s:data, s:queue, s:file_explorers)

function! s:suite.should_not_init_project_lint_if_no_file_explorers_are_detected() abort
  let l:result = s:project_lint.init()
  call s:assert.equals(s:project_lint.running, v:false)
  call s:assert.false(l:result)
endfunction

function! s:suite.should_init_if_one_of_file_explorers_are_detected() abort
  let g:loaded_defx = 1
  call s:assert.true(s:file_explorers.has_defx())
  call s:assert.true(s:file_explorers.has_valid_file_explorer())
  let l:result = s:project_lint.init()
  call s:assert.equals(s:project_lint.running, v:true)
  call s:assert.length_of(s:queue.list, 1)
  sleep 50m
  call s:assert.equals(s:project_lint.running, v:false)
  call s:assert.length_of(s:queue.list, 0)
  call s:assert.length_of(s:data.get(), 1)
  call s:assert.equals(s:data.get_item(s:file_mock), { 'my_linter': 1 })
endfunction
