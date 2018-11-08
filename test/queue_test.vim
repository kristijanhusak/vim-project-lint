let s:suite = themis#suite('queue')
let s:assert = themis#helper('assert')
let s:file_mock = printf('%s/file.js', getcwd())

let s:linter_mock = {'name': 'my_linter', 'stream': 'stdout'}
function! s:linter_mock.command() abort
  return printf('echo "%s"', s:file_mock)
endfunction
function! s:linter_mock.file_command(file) abort
  return printf('echo "%s"', s:file_mock)
endfunction
function! s:linter_mock.parse(msg) abort
  return a:msg
endfunction

let s:data = project_lint#data#new()
let s:job = project_lint#job#new()
let s:queue = project_lint#queue#new(s:job, s:data)

function! s:suite.should_be_empty_on_start() abort
  call s:assert.true(s:queue.is_empty())
  call s:assert.equals(s:queue.get_running_linters(), {'project': [], 'files': []})
endfunction

function! s:suite.should_add_project_job() abort
  let l:id = s:queue.add(s:linter_mock)
  call s:assert.false(s:queue.is_empty())
  call s:assert.equals(s:queue.get_running_linters(), {'project': ['my_linter'], 'files': []})
  call s:assert.equals(v:true, s:queue.is_linting_project())
  call s:assert.length_of(s:queue.list, 1)
  call s:assert.has_key(s:queue.list, 1)
  call s:assert.equals(s:queue.list[1].linter.name, s:linter_mock.name)
  call s:assert.empty(s:queue.list[1].file)
  sleep 50m
  call s:assert.true(s:queue.is_empty())
  call s:assert.equals(s:queue.get_running_linters(), {'project': [], 'files': []})
  call s:assert.equals(v:false, s:queue.is_linting_project())
  call s:assert.empty(s:queue.list)
  call s:assert.has_key(s:data.paths, s:file_mock)
  call s:assert.has_key(s:data.paths[s:file_mock], 'my_linter')
  call s:assert.equals(s:data.paths[s:file_mock].my_linter, 1)
endfunction

function! s:suite.should_add_file_job() abort
  let l:id = s:queue.add_file(s:linter_mock, s:file_mock)
  call s:assert.false(s:queue.is_empty())
  call s:assert.equals(s:queue.get_running_linters(), {'project': [], 'files': ['my_linter']})
  call s:assert.equals(v:false, s:queue.is_linting_project())
  call s:assert.length_of(s:queue.list, 1)
  call s:assert.has_key(s:queue.list, 2)
  call s:assert.equals(s:queue.list[2].linter.name, s:linter_mock.name)
  call s:assert.equals(s:file_mock, s:queue.list[2].file)
  call s:assert.equals(v:false, s:queue.is_linting_project())
  call s:assert.equals(v:true, s:queue.already_linting_file(s:linter_mock, s:file_mock))
  sleep 50m
  call s:assert.true(s:queue.is_empty())
  call s:assert.equals(s:queue.get_running_linters(), {'project': [], 'files': []})
  call s:assert.equals(v:false, s:queue.already_linting_file(s:linter_mock, s:file_mock))
  call s:assert.empty(s:queue.list)
  call s:assert.has_key(s:data.paths, s:file_mock)
  call s:assert.has_key(s:data.paths[s:file_mock], 'my_linter')
  call s:assert.equals(s:data.paths[s:file_mock].my_linter, 1)
endfunction


function! s:suite.should_mark_file_as_valid_and_remove_from_data() abort
  function! s:linter_mock.file_command(file) abort
    return 'echo ""'
  endfunction
  let l:id = s:queue.add_file(s:linter_mock, s:file_mock)
  call s:assert.false(s:queue.is_empty())
  call s:assert.equals(s:queue.get_running_linters(), {'project': [], 'files': ['my_linter']})
  call s:assert.equals(v:false, s:queue.is_linting_project())
  call s:assert.length_of(s:queue.list, 1)
  call s:assert.has_key(s:queue.list, 3)
  call s:assert.equals(s:queue.list[3].linter.name, s:linter_mock.name)
  call s:assert.equals(s:file_mock, s:queue.list[3].file)
  call s:assert.equals(v:false, s:queue.is_linting_project())
  call s:assert.equals(v:true, s:queue.already_linting_file(s:linter_mock, s:file_mock))
  sleep 50m
  call s:assert.true(s:queue.is_empty())
  call s:assert.equals(s:queue.get_running_linters(), {'project': [], 'files': []})
  call s:assert.equals(v:false, s:queue.already_linting_file(s:linter_mock, s:file_mock))
  call s:assert.empty(s:queue.list)
  call s:assert.key_not_exists(s:data.paths, s:file_mock)
  function! s:linter_mock.file_command(file) abort
    return printf('echo "%s"', s:file_mock)
  endfunction
endfunction

function! s:suite.should_add_file_to_after_project_lint_list_queue() abort
  let l:id = s:queue.add(s:linter_mock)
  let l:file_job_id = s:queue.add_file(s:linter_mock, s:file_mock)
  call s:assert.false(s:queue.is_empty())
  call s:assert.equals(s:queue.get_running_linters(), {'project': ['my_linter'], 'files': []})
  call s:assert.equals(v:true, s:queue.is_linting_project())
  call s:assert.length_of(s:queue.list, 1)
  call s:assert.has_key(s:queue.list, 4)
  call s:assert.length_of(s:queue.post_project_lint_file_list, 1)
  call s:assert.equals(s:queue.post_project_lint_file_list[0], {'linter': s:linter_mock, 'file': s:file_mock })
  call s:assert.equals(s:queue.list[4].linter.name, s:linter_mock.name)
  call s:assert.empty(s:queue.list[4].file)
  sleep 50m
  call s:assert.false(s:queue.is_empty())
  call s:assert.equals(s:queue.get_running_linters(), {'project': [], 'files': ['my_linter']})
  call s:assert.equals(v:false, s:queue.is_linting_project())
  call s:assert.length_of(s:queue.list, 1)
  call s:assert.has_key(s:queue.list, 5)
  call s:assert.equals(s:queue.list[5].linter.name, s:linter_mock.name)
  call s:assert.equals(s:file_mock, s:queue.list[5].file)
  call s:assert.equals(v:false, s:queue.is_linting_project())
  call s:assert.equals(v:true, s:queue.already_linting_file(s:linter_mock, s:file_mock))
  call s:assert.empty(s:queue.post_project_lint_file_list)
  sleep 50m
  call s:assert.true(s:queue.is_empty())
  call s:assert.equals(s:queue.get_running_linters(), {'project': [], 'files': []})
  call s:assert.equals(v:false, s:queue.already_linting_file(s:linter_mock, s:file_mock))
  call s:assert.empty(s:queue.list)
  call s:assert.has_key(s:data.paths, s:file_mock)
  call s:assert.has_key(s:data.paths[s:file_mock], 'my_linter')
  call s:assert.equals(s:data.paths[s:file_mock].my_linter, 1)
endfunction
