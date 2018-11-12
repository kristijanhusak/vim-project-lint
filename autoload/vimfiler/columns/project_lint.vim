"=============================================================================
" FILE: type.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! vimfiler#columns#project_lint#define() abort
  return s:column
endfunction

let s:column = {
      \ 'name' : 'project_lint',
      \ 'description' : 'Get lint status of a file',
      \ 'syntax' : 'vimfilerColumn__ProjectLint',
      \ }

function! s:column.length(files, context) abort
  return 3
endfunction

function! s:column.define_syntax(context) abort
  silent! exe printf('hi default vimfilerColumn__ProjectLint %s', g:project_lint#error_icon_color)
endfunction

function! s:column.get(file, context) abort
  if has_key(g:project_lint#get_data(), a:file.action__path)
    return '['.g:project_lint#error_icon.']'
  endif

  return '  '
endfunction
