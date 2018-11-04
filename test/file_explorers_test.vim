let s:suite = themis#suite('file_explorers')
let s:assert = themis#helper('assert')

let s:file_explorers = project_lint#file_explorers#new()

function! s:suite.should_not_detect_any_file_explorers() abort
  call s:assert.equals(0, s:file_explorers.has_valid_file_explorer())
endfunction

function! s:suite.should_detect_defx() abort
  let g:loaded_defx = 1
  call s:assert.equals(1, s:file_explorers.has_defx())
  call s:assert.equals(1, s:file_explorers.has_valid_file_explorer())
  unlet g:loaded_defx
endfunction

function! s:suite.should_detect_nerdtree() abort
  let g:loaded_nerd_tree = 1
  call s:assert.equals(0, s:file_explorers.has_defx())
  call s:assert.equals(1, s:file_explorers.has_nerdtree())
  call s:assert.equals(1, s:file_explorers.has_valid_file_explorer())
  unlet g:loaded_nerd_tree
endfunction

function! s:suite.should_detect_vimfiler() abort
  let g:loaded_vimfiler = 1
  call s:assert.equals(0, s:file_explorers.has_defx())
  call s:assert.equals(0, s:file_explorers.has_nerdtree())
  call s:assert.equals(1, s:file_explorers.has_vimfiler())
  call s:assert.equals(1, s:file_explorers.has_valid_file_explorer())
  unlet g:loaded_vimfiler
endfunction

function! s:suite.should_register_callbacks() abort
  let g:loaded_defx = 1
  let g:loaded_vimfiler = 1
  call s:file_explorers.register()
  call s:assert.length_of(s:file_explorers.explorers, 2)
endfunction
