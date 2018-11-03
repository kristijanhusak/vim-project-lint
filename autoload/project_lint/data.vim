let s:data = {}

function! project_lint#data#new() abort
  return s:data.new()
endfunction

function! s:data.new() abort
  let l:instance = copy(self)
  let l:instance.paths = {}
  let l:instance.cache = {}
  let l:instance.use_cache = v:false
  return l:instance
endfunction

function! s:data.get() abort
  if self.use_cache
    return self.cache
  endif

  return self.paths
endfunction

function! s:data.check_cache() abort
  let l:filename = self.cache_filename()
  if filereadable(l:filename)
    let self.cache = json_decode(readfile(l:filename))
    let self.use_cache = v:true
    return v:true
  endif
  return v:false
endfunction

function! s:data.add(linter, file) abort
  let l:should_cache_dirs = self.add_single(a:linter, a:file, v:false)
  let l:dir = fnamemodify(a:file, ':h')

  if l:dir ==? getcwd() || !l:should_cache_dirs
    return
  endif

  while l:dir !=? getcwd()
    call self.add_single(a:linter, l:dir, v:true)
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
endfunction

function! s:data.remove(linter, file) abort
  let l:should_cache_dirs = self.remove_single(a:linter, a:file)
  let l:dir = fnamemodify(a:file, ':h')

  if l:dir ==? getcwd()
    return
  endif

  while l:dir !=? getcwd()
    call self.remove_single(a:linter, l:dir)
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
endfunction

function! s:data.add_single(linter, file, is_dir) abort
  if !has_key(self.paths, a:file)
    let self.paths[a:file] = {}
    let self.paths[a:file][a:linter.name] = 1
    return v:true
  endif

  if !has_key(self.paths[a:file], a:linter.name)
    let self.paths[a:file][a:linter.name] = 1
    return v:true
  endif

  "Do not mark same thing as invalid more than once
  if !a:is_dir && self.paths[a:file][a:linter.name] > 0
    return v:false
  endif

  let self.paths[a:file][a:linter.name] += 1
  return v:true
endfunction

function! s:data.remove_single(linter, file) abort
  if !has_key(self.paths, a:file) || !has_key(self.paths[a:file], a:linter.name)
    return
  endif

  if self.paths[a:file][a:linter.name] > 0
    let self.paths[a:file][a:linter.name] -= 1
  endif


  if self.paths[a:file][a:linter.name] <=? 0
    call remove(self.paths[a:file], a:linter.name)
  endif

  if empty(self.paths[a:file])
    call remove(self.paths, a:file)
  endif
endfunction

function! s:data.cache_filename() abort
  let l:fname = printf('~/.cache/vim-project-lint/%s.json',
        \  tolower(substitute(getcwd(), '/', '-', 'g'))[1:])
  return fnamemodify(l:fname, ':p')
endfunction

function! s:data.use_fresh_data() abort
  let self.use_cache = v:false
  let self.cache = {}
endfunction

function! s:data.cache_to_file() abort
  let l:filename = self.cache_filename()

  if filereadable(l:filename)
    return writefile([json_encode(self.paths)], l:filename)
  endif

  let l:cache_dir = fnamemodify('~/.cache/vim-project-lint', ':p')
  if !isdirectory(l:cache_dir)
    call mkdir(l:cache_dir, 'p')
  endif

  return writefile([json_encode(self.paths)], l:filename)
endfunction

