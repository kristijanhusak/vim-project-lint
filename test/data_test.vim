let s:suite = themis#suite('data')
let s:assert = themis#helper('assert')

let s:cache_dir = expand('<sfile>:p:h')
let s:cache_file = printf('%s/%s.json', s:cache_dir, tolower(substitute(getcwd(), '/', '-', 'g'))[1:])

function! s:suite.before() abort
  if filereadable(s:cache_file)
    call delete(s:cache_file)
  endif
endfunction

let s:data = project_lint#data#new()

function s:get_path(path) abort
  return printf('%s/%s', getcwd(), a:path)
endfunction

let s:linter = {'name': 'vinter'}

function! s:suite.should_be_empty_on_start() abort
  call s:assert.empty(s:data.get())
endfunction

function! s:suite.should_add_file_and_all_its_parents_folders_until_root() abort
  call s:data.add(s:linter, s:get_path('nested/path/inside/folders/myfile.vim'))
  call s:assert.has_key(s:data.get(), s:get_path('nested'))
  call s:assert.equals(s:data.get_item(s:get_path('nested')), {'vinter': 1})
  call s:assert.has_key(s:data.get(), s:get_path('nested/path'))
  call s:assert.equals(s:data.get_item(s:get_path('nested/path')), {'vinter': 1})
  call s:assert.has_key(s:data.get(), s:get_path('nested/path/inside'))
  call s:assert.equals(s:data.get_item(s:get_path('nested/path/inside')), {'vinter': 1})
  call s:assert.has_key(s:data.get(), s:get_path('nested/path/inside/folders'))
  call s:assert.equals(s:data.get_item(s:get_path('nested/path/inside/folders')), {'vinter': 1})
  call s:assert.has_key(s:data.get(), s:get_path('nested/path/inside/folders/myfile.vim'))
  call s:assert.equals(s:data.get_item(s:get_path('nested/path/inside/folders/myfile.vim')), {'vinter': 1})
endfunction

function! s:suite.should_remove_file_and_all_its_parents_folders_until_root() abort
  call s:data.remove(s:linter, s:get_path('nested/path/inside/folders/myfile.vim'))
  call s:assert.key_not_exists(s:data.get(), s:get_path('nested'))
  call s:assert.key_not_exists(s:data.get(), s:get_path('nested/path'))
  call s:assert.key_not_exists(s:data.get(), s:get_path('nested/path/inside'))
  call s:assert.key_not_exists(s:data.get(), s:get_path('nested/path/inside/folders'))
  call s:assert.key_not_exists(s:data.get(), s:get_path('nested/path/inside/folders/myfile.vim'))
endfunction

function! s:suite.should_not_add_a_file_if_not_part_of_project_root() abort
  call s:data.add(s:linter, '/some/invalid/file/path.js')
  call s:assert.key_not_exists(s:data.get(), '/some/invalid/file/path.js')
endfunction

function! s:suite.should_add_file_and_all_its_parents_folders_until_root_and_cache_to_file() abort
  call s:data.add(s:linter, s:get_path('nested/path/inside/folders/myfile.vim'))
  call s:assert.has_key(s:data.get(), s:get_path('nested'))
  call s:assert.equals(s:data.get_item(s:get_path('nested')), {'vinter': 1})
  call s:assert.has_key(s:data.get(), s:get_path('nested/path'))
  call s:assert.equals(s:data.get_item(s:get_path('nested/path')), {'vinter': 1})
  call s:assert.has_key(s:data.get(), s:get_path('nested/path/inside'))
  call s:assert.equals(s:data.get_item(s:get_path('nested/path/inside')), {'vinter': 1})
  call s:assert.has_key(s:data.get(), s:get_path('nested/path/inside/folders'))
  call s:assert.equals(s:data.get_item(s:get_path('nested/path/inside/folders')), {'vinter': 1})
  call s:assert.has_key(s:data.get(), s:get_path('nested/path/inside/folders/myfile.vim'))
  call s:assert.equals(s:data.get_item(s:get_path('nested/path/inside/folders/myfile.vim')), {'vinter': 1})
  let g:project_lint#cache_dir = s:cache_dir
  call s:assert.equals(s:data.cache_filename(), s:cache_file)
  call s:assert.false(filereadable(s:cache_file))
  call s:data.cache_to_file()
  call s:assert.true(filereadable(s:cache_file))
  let l:file_data = json_decode(readfile(s:cache_file)[0])
  call s:assert.has_key(l:file_data, s:get_path('nested'))
  call s:assert.equals(l:file_data[s:get_path('nested')], {'vinter': 1})
  call s:assert.has_key(l:file_data, s:get_path('nested/path'))
  call s:assert.equals(l:file_data[s:get_path('nested/path')], {'vinter': 1})
  call s:assert.has_key(l:file_data, s:get_path('nested/path/inside'))
  call s:assert.equals(l:file_data[s:get_path('nested/path/inside')], {'vinter': 1})
  call s:assert.has_key(l:file_data, s:get_path('nested/path/inside/folders'))
  call s:assert.equals(l:file_data[s:get_path('nested/path/inside/folders')], {'vinter': 1})
  call s:assert.has_key(l:file_data, s:get_path('nested/path/inside/folders/myfile.vim'))
  call s:assert.equals(l:file_data[s:get_path('nested/path/inside/folders/myfile.vim')], {'vinter': 1})
endfunction

function! s:suite.should_use_cache_if_toggled_on() abort
  let s:data.paths = {'file': 1 }
  let s:data.cache = {'cache_file': 1 }
  call s:assert.equals(v:false, s:data.use_cache)
  call s:assert.has_key(s:data.get(), 'file')
  call s:assert.key_not_exists(s:data.get(), 'cache_file')
  let s:data.use_cache = v:true
  call s:assert.key_not_exists(s:data.get(), 'file')
  call s:assert.has_key(s:data.get(), 'cache_file')
  let s:data.paths = {}
  let s:data.cache = {}
  let s:data.use_cache = v:false
endfunction
