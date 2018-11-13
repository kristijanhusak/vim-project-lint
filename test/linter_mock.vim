function! s:get_mock() abort
  return s:linter_mock
endfunctio

function! s:get_mock_file() abort
  return s:file_mock
endfunction

let s:file_mock = printf('%s/file.js', getcwd())
let s:linter_mock = {
      \ 'name': 'my_linter',
      \ 'stream': 'stdout',
      \ 'filetype': ['javascript', 'javascript.jsx', 'typescript'],
      \ }

function! s:linter_mock.command() abort
  return printf('echo "%s"', s:file_mock)
endfunction

function! s:linter_mock.file_command(file) abort
  return printf('echo "%s"', s:file_mock)
endfunction

function! s:linter_mock.check_executable() abort
  return v:true
endfunction

function! s:linter_mock.detect() abort
  return v:true
endfunction

function! s:linter_mock.parse(msg) abort
  return {'path': a:msg, 'severity': 'e'}
  return a:msg
endfunction

function! s:linter_mock.parse_messages(messages) abort
  return a:messages
endfunction
