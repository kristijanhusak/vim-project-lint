let s:linters = {}
let s:filetypes = {
      \ 'javascript': ['project_lint#utils#has_file_in_cwd', 'package.json'],
      \ 'python': ['project_lint#utils#find_extension', 'py'],
      \ 'go': ['project_lint#utils#find_extension', 'go'],
      \ 'vim': ['project_lint#utils#find_extension', 'vim'],
      \ }

function! project_lint#linters#new() abort
  return s:linters.new()
endfunction

function s:linters.new() abort
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

function! s:linters.add(linter) abort
  if !has_key(self.items, a:linter.name)
    let self.items[a:linter.name] = a:linter
  endif
endfunction