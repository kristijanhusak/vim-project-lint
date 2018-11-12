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
  silent! exe printf("syntax match vimfilerColumn__ProjectLintError '\[%s\]' containedin=vimfilerColumn__ProjectLint", g:project_lint#error_icon)
  silent! exe printf("syntax match vimfilerColumn__ProjectLintWarning '\[%s\]' containedin=vimfilerColumn__ProjectLint", g:project_lint#warning_icon)
  silent! exe printf('hi default vimfilerColumn__ProjectLintError %s', g:project_lint#error_icon_color)
  silent! exe printf('hi default vimfilerColumn__ProjectLintWarning %s', g:project_lint#warning_icon_color)
endfunction

function! s:column.get(file, context) abort
  let l:default = '   '
  let l:data = get(g:project_lint#get_data(), a:file.action__path, {})
  if empty(l:data)
    return l:default
  endif

  if get(l:data, 'e', 0) > 0
    return '['.g:project_lint#error_icon.']'
  endif

  if get(l:data, 'w', 0) > 0
    return '['.g:project_lint#warning_icon.']'
  endif

  return l:default
endfunction
