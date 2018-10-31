let g:defx_lint#data = []
let g:defx_lint#cache = {}
let s:linted = 0

function! defx_lint#exec(path) abort
  let l:is_file = a:path !=? getcwd()
  if s:linted && !l:is_file
    return
  endif
  let s:linted = 1
  echom printf('Linting %s...', l:is_file ? 'File' : 'Project')
  call jobstart(['./node_modules/.bin/eslint', '--format=unix', a:path], {
        \ 'on_stdout': function('s:on_stdout'),
        \ 'on_stderr': function('s:on_stdout'),
        \ 'stdout_buffered': v:true,
        \ 'path': a:path,
        \ 'cwd': getcwd(),
        \ })
endfunction

function! s:on_stdout(id, message, event) dict
  if a:event !=? 'stdout'
    return
  endif

  let l:is_file = self.path !=? self.cwd
  let l:remove_from_cache = v:true

  for l:msg in a:message
    let l:items = split(l:msg, ':')
    if len(l:items) > 0
      if l:is_file && l:items[0] ==? self.path
        let l:remove_from_cache = v:false
      endif
      if index(g:defx_lint#data, l:items[0]) < 0
        call add(g:defx_lint#data, l:items[0])
        call defx_lint#cache_put(l:items[0], 1)
      endif
    endif
  endfor

  if l:is_file && l:remove_from_cache
    call defx_lint#cache_remove(self.path)
  endif

  echom 'Finished.'
  call defx#_do_action('redraw', [])
endfunction

function! defx_lint#cache_put(path, is_invalid) abort
  let g:defx_lint#cache[a:path] = a:is_invalid
endfunction

function! defx_lint#cache_remove(path) abort
  call s:remove_from_cache(a:path)

  let l:index = index(g:defx_lint#data, a:path)
  if l:index > 0
    call remove(g:defx_lint#data, l:index)
  endif

  for l:path in keys(g:defx_lint#cache)
    if escape(a:path, '/') =~? printf('^%s', escape(l:path, '/'))
      call s:remove_from_cache(l:path)
    endif
  endfor
endfunction

function defx_lint#refresh(file) abort
  call defx_lint#exec(a:file)
endfunction

function s:remove_from_cache(item) abort
  if has_key(g:defx_lint#cache, a:item)
    call remove(g:defx_lint#cache, a:item)
  endif
endfunction

augroup defx_lint
  autocmd BufWritePost * call defx_lint#refresh(expand('<afile>:p'))
augroup END
