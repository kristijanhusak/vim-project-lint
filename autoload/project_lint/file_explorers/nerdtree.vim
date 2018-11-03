function! project_lint#file_explorers#nerdtree#register() abort
  augroup project_lint_nerdtree
    autocmd FileType nerdtree call s:setup_highlighting()
  augroup END
  call g:NERDTreePathNotifier.AddListener('init', 'project_lint#file_explorers#nerdtree#listener')
  call g:NERDTreePathNotifier.AddListener('refresh', 'project_lint#file_explorers#nerdtree#listener')
  call g:NERDTreePathNotifier.AddListener('refreshFlags', 'project_lint#file_explorers#nerdtree#listener')

  call add(g:project_lint#callbacks, 'project_lint#file_explorers#nerdtree#callback')
  call s:setup_highlighting()
endfunction

function! project_lint#file_explorers#nerdtree#listener(event) abort
  let l:subject = a:event.subject
  let l:path = l:subject.str()
  call l:subject.flagSet.clearFlags('project_lint')
  if has_key(g:project_lint#data.get(), l:path)
    call l:subject.flagSet.addFlag('project_lint', g:project_lint#icon)
  endif
endfunction

function! project_lint#file_explorers#nerdtree#callback(...) abort
  if !g:NERDTree.IsOpen() && !exists('b:NERDTree')
    return
  endif

  if a:0 > 0
    return s:refresh_file(a:1)
  endif

  return s:refresh_tree()
endfunction

function! s:refresh_file(file) abort
  if !g:NERDTree.IsOpen()
    return
  endif

  let l:winnr = winnr()
  let l:altwinnr = winnr('#')

  call g:NERDTree.CursorToTreeWin()
  let l:node = b:NERDTree.root.findNode(g:NERDTreePath.New(a:file))
  if empty(l:node)
    return
  endif
  call l:node.refreshFlags()
  let l:node = l:node.parent
  while !empty(l:node)
    call l:node.refreshDirFlags()
    let l:node = l:node.parent
  endwhile

  call NERDTreeRender()

  exec l:altwinnr . 'wincmd w'
endfunction

function! s:refresh_tree() abort
  if exists('b:NERDTree')
    call b:NERDTree.root.refreshFlags()
    return NERDTreeRender()
  endif

  " Do not update when a special buffer is selected
  if !empty(&l:buftype)
    return
  endif

  let l:winnr = winnr()
  let l:altwinnr = winnr('#')

  call g:NERDTree.CursorToTreeWin()
  call b:NERDTree.root.refreshFlags()
  call NERDTreeRender()

  exec l:altwinnr . 'wincmd w'
  exec l:winnr . 'wincmd w'
endfunction

function! s:setup_highlighting() abort
  let l:padding = ''
  if exists('g:loaded_nerdtree_git_status')
    let l:padding = '[^\(\[\|\]\)]*\zs'
  endif
  silent! exe printf('syn match NERDTreeProjectLintIcon #%s%s# containedin=NERDTreeFlags', l:padding, g:project_lint#icon)
  silent! exe printf('hi default NERDTreeProjectLintIcon %s', g:project_lint#icon_color)
endfunction
