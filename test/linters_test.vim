let s:suite = themis#suite('linters')
let s:assert = themis#helper('assert')
let s:scope =  themis#helper('scope')
let s:mock_functions = s:scope.funcs('test/linter_mock.vim')
let s:linter_mock = s:mock_functions.get_mock()
let s:file_mock = s:mock_functions.get_mock_file()

function! s:suite.after() abort
  let g:project_lint#enabled_linters = {}
endfunction

let s:linters = project_lint#linters#new()

function! s:suite.should_be_empty_on_start() abort
  call s:assert.empty(s:linters.items)
endfunction

function! s:suite.should_add_linter_to_list() abort
  call s:linters.add(s:linter_mock)
  call s:assert.length_of(s:linters.items, 1)
endfunction

function! s:suite.should_return_all_linter_filetypes_as_enabled_if_global_setting_for_them_is_not_defined() abort
  call s:assert.equals(s:linters.get_enabled_filetypes(s:linter_mock), ['javascript', 'javascript.jsx', 'typescript'])
endfunction

function! s:suite.should_return_only_js_and_ts_as_enabled_filetype() abort
  let g:project_lint#enabled_linters = {'javascript.jsx': []}
  call s:assert.equals(s:linters.get_enabled_filetypes(s:linter_mock), ['javascript', 'typescript'])
endfunction

function! s:suite.should_return_only_js_as_enabled_filetype_because_linter_not_defined_for_other_filetypes() abort
  let g:project_lint#enabled_linters = {'javascript.jsx': ['other_linter'], 'typescript': ['tslint'] }
  call s:assert.equals(s:linters.get_enabled_filetypes(s:linter_mock), ['javascript'])
endfunction
