let s:file_explorers = {}

function! project_lint#file_explorers#new() abort
  return s:file_explorers.new()
endfunction

function! s:file_explorers.new() abort
  let l:instance = copy(self)
  let l:instance.explorers = []
  return l:instance
endfunction

function! s:file_explorers.has_valid_file_explorer() abort
  return  self.has_defx() || self.has_nerdtree() || self.has_vimfiler()
endfunction

function! s:file_explorers.register() abort
  if self.has_defx()
    call add(self.explorers, project_lint#file_explorers#defx#new())
  endif

  if self.has_nerdtree()
    call add(self.explorers, project_lint#file_explorers#nerdtree#new())
  endif

  if self.has_vimfiler()
    call add(self.explorers, project_lint#file_explorers#vimfiler#new())
  endif
endfunction

function! s:file_explorers.trigger_callbacks(...) abort
  for l:explorer in self.explorers
    call call(l:explorer.callback, a:000)
  endfor
endfunction

function! s:file_explorers.has_defx() abort
  return exists('g:loaded_defx')
endfunction

function! s:file_explorers.has_nerdtree() abort
  return exists('g:loaded_nerd_tree')
endfunction

function! s:file_explorers.has_vimfiler() abort
  return exists('g:loaded_vimfiler')
endfunction
