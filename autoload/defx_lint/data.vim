let s:data = {}

function! defx_lint#data#new() abort
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

function! s:data.check_cache()
  let l:filename = self.cache_filename()
  if filereadable(l:filename)
    let self.cache = json_decode(readfile(l:filename))
    let self.use_cache = v:true
    return v:true
  endif
  return v:false
endfunction

function! s:data.add(file) abort
  let l:should_cache_dirs = self.add_single(a:file, v:false)
  let l:dir = fnamemodify(a:file, ':h')

  if l:dir ==? getcwd() || !l:should_cache_dirs
    return
  endif

  while l:dir !=? getcwd()
    call self.add_single(l:dir, v:true)
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
endfunction

function! s:data.remove(file) abort
  let l:should_cache_dirs = self.remove_single(a:file)
  let l:dir = fnamemodify(a:file, ':h')

  if l:dir ==? getcwd()
    return
  endif

  while l:dir !=? getcwd()
    call self.remove_single(l:dir)
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
endfunction

function! s:data.add_single(file, is_dir) abort
  if !has_key(self.paths, a:file)
    let self.paths[a:file] = 1
    return v:true
  endif

  "Do not mark same thing as invalid more than once
  if !a:is_dir && self.paths[a:file] > 0
    return v:false
  endif

  let self.paths[a:file] += 1
  return v:true
endfunction

function! s:data.remove_single(file) abort
  if !has_key(self.paths, a:file)
    return
  endif

  if self.paths[a:file] > 0
    let self.paths[a:file] -= 1
  endif

  if self.paths[a:file] <=? 0
    call remove(self.paths, a:file)
  endif
endfunction

function! s:data.cache_filename() abort
  let l:fname = printf('~/.cache/defx-lint/%s.json',
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

  let l:cache_dir = fnamemodify('~/.cache/defx-lint', ':p')
  if !isdirectory(l:cache_dir)
    call mkdir(l:cache_dir, 'p')
  endif

  return writefile([json_encode(self.paths)], l:filename)
endfunction

