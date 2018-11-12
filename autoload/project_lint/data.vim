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

function! s:data.get_item(item) abort
  return get(self.get(), a:item, {})
endfunction

function! s:data.check_cache() abort
  let l:filename = self.cache_filename()
  if filereadable(l:filename)
    let self.cache = json_decode(readfile(l:filename)[0])
    let self.use_cache = v:true
    return v:true
  endif
  return v:false
endfunction

function! s:data.add(linter, file) abort
  if a:file.path !~? printf('^%s', g:project_lint#root)
    return
  endif
  let l:should_cache_dirs = self.add_single(a:linter, a:file, v:false)
  let l:dir = fnamemodify(a:file.path, ':h')

  if l:dir ==? g:project_lint#root || !l:should_cache_dirs
    return
  endif

  while l:dir !=? g:project_lint#root
    call self.add_single(a:linter, extend(copy(a:file), {'path': l:dir }), v:true)
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
endfunction

function! s:data.remove(linter, file) abort
  if a:file !~? printf('^%s', g:project_lint#root)
    return
  endif
  call self.remove_single(a:linter, a:file)
  let l:dir = fnamemodify(a:file, ':h')

  if l:dir ==? g:project_lint#root
    return
  endif

  while l:dir !=? g:project_lint#root
    call self.remove_single(a:linter, l:dir)
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
endfunction

function! s:data.add_single(linter, file, is_dir) abort
  if !has_key(self.paths, a:file.path)
    let self.paths[a:file.path] = {}
    let self.paths[a:file.path][a:linter.name] = { 'w': 0, 'e': 0 }
    let self.paths[a:file.path][a:linter.name][a:file.severity] = 1
    return v:true
  endif

  if !has_key(self.paths[a:file.path], a:linter.name)
    let self.paths[a:file.path][a:linter.name] = { 'w': 0, 'e': 0 }
    let self.paths[a:file.path][a:linter.name][a:file.severity] = 1
    return v:true
  endif

  "Do not mark same thing as invalid more than once
  if !a:is_dir && self.paths[a:file.path][a:linter.name][a:file.severity] > 0
    return v:false
  endif

  let self.paths[a:file.path][a:linter.name][a:file.severity] += 1
  return v:true
endfunction

function! s:data.remove_single(linter, file) abort
  if !has_key(self.paths, a:file) || !has_key(self.paths[a:file], a:linter.name)
    return
  endif

  if self.paths[a:file][a:linter.name].w > 0
    let self.paths[a:file][a:linter.name].w -= 1
  endif
  if self.paths[a:file][a:linter.name].e > 0
    let self.paths[a:file][a:linter.name].e -= 1
  endif

  if self.paths[a:file][a:linter.name].w <=? 0 && self.paths[a:file][a:linter.name].e <=? 0
    call remove(self.paths[a:file], a:linter.name)
  endif

  if len(self.paths[a:file]) <= 2
    call remove(self.paths, a:file)
  endif
endfunction

function! s:data.cache_filename() abort
  let l:filename = tolower(substitute(g:project_lint#root, '/', '-', 'g'))[1:]
  let l:filename_path = printf('%s/%s.json', g:project_lint#cache_dir, l:filename)
  return fnamemodify(l:filename_path, ':p')
endfunction

function! s:data.use_fresh_data() abort
  let self.use_cache = v:false
  let self.cache = {}
endfunction

function! s:data.add_total_severity_counters(...) abort
  if a:0 <=? 0
    for l:file in keys(self.paths)
      call self.add_single_severity_counter(l:file)
    endfor
    return
  endif

  let l:file = a:1
  let l:dir = fnamemodify(l:file, ':h')
  let l:is_added = self.add_single_severity_counter(l:file)

  if l:dir ==? g:project_lint#root || !l:is_added
    return
  endif

  while l:dir !=? g:project_lint#root
    call self.add_single_severity_counter(l:dir)
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
endfunction

function! s:data.add_single_severity_counter(file) abort
  if !has_key(self.paths, a:file)
    return v:false
  endif
  let l:warnings = 0
  let l:errors = 0
  for [l:linter, l:data] in items(self.paths[a:file])
    if l:linter ==? 'w' || l:linter ==? 'e'
      continue
    endif

    if get(l:data, 'w', 0) > 0
      let l:warnings = 1
    endif

    if get(l:data, 'e', 0) > 0
      let l:errors = 1
    endif
  endfor

  let self.paths[a:file].w = l:warnings
  let self.paths[a:file].e = l:errors
  return v:true
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

