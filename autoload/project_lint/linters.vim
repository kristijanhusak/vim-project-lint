let s:linters = {}
let s:filetypes = {
      \ 'javascript': ['project_lint#utils#has_file_in_cwd', 'package.json'],
      \ 'typescript': ['project_lint#utils#find_extension', 'ts'],
      \ 'python': ['project_lint#utils#find_extension', 'py'],
      \ 'go': ['project_lint#utils#find_extension', 'go'],
      \ 'vim': ['project_lint#utils#find_extension', 'vim'],
      \ 'css': ['project_lint#utils#find_extension', 'css'],
      \ 'scss': ['project_lint#utils#find_extension', 'scss'],
      \ 'sass': ['project_lint#utils#find_extension', 'sass'],
      \ 'ruby': ['project_lint#utils#find_extension', 'rb'],
      \ 'php': ['project_lint#utils#find_extension', 'php'],
      \ 'lua': ['project_lint#utils#find_extension', 'lua'],
      \ 'rust': ['project_lint#utils#find_extension', 'rs'],
      \ }

function! project_lint#linters#new() abort
  return s:linters.new()
endfunction

function! s:linters.new() abort
  let l:instance = copy(self)
  let l:instance.items = {}
  return l:instance
endfunction

function! s:linters.load() abort
  for [l:filetype, l:func] in items(s:filetypes)
    let l:detected = call(l:func[0], [l:func[1]])
    if !empty(l:detected)
      silent! exe printf('runtime! project_linters/%s/*', l:filetype)
    endif
  endfor
endfunction

function! s:linters.get() abort
  return values(self.items)
endfunction

function! s:linters.get_linter(name) abort
  return get(self.items, a:name, {})
endfunction

function! s:linters.add(linter) abort
  if !has_key(self.items, a:linter.name)
    let self.items[a:linter.name] = a:linter
  endif
endfunction

function! s:linters.get_enabled_filetypes(linter) abort
  let l:filetypes = copy(a:linter.filetype)
  for l:ft in l:filetypes
    if !has_key(g:project_lint#enabled_linters, l:ft)
      continue
    endif
    let l:data = g:project_lint#enabled_linters[l:ft]
    if index(l:data, a:linter.name) < 0
      call remove(l:filetypes, index(l:filetypes, l:ft))
    endif
  endfor

  return l:filetypes
endfunction

function! s:linters.is_linter_enabled(linter) abort
  return !empty(self.get_enabled_filetypes(a:linter))
endfunction

function! s:linters.is_linter_enabled_for_filetype(linter, filetype) abort
  if !has_key(g:project_lint#enabled_linters, a:filetype)
    return v:true
  endif
  return index(g:project_lint#enabled_linters[a:filetype], a:linter.name) > -1
endfunction
