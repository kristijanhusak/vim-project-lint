let s:mypy = {}

function! s:mypy.new() abort
  let l:instance = copy(self)
  let l:instance.name = 'mypy'
  let l:instance.cmd = l:instance.executable()
  let l:instance.cmd_args = get(g:defx_lint#linter_args, 'mypy', '')
  let l:instance.stream = 'stdout'
  let l:instance.filetype = ['python']
  let l:instance.files = []
  return l:instance
endfunction

function! s:mypy.detect() abort
  if empty(self.cmd)
    return v:false
  endif
  let self.files = defx_lint#utils#find_extension('py')
  return len(self.files) > 0
endfunction

function! s:mypy.detect_for_file() abort
  return index(self.filetype, &filetype) > -1
endfunction

function! s:mypy.executable() abort
  if executable('mypy')
    return 'mypy'
  endif

  return ''
endfunction

function! s:mypy.command() abort
  let l:target = '.'
  if len(self.files) > 0
    let l:target = fnamemodify(self.files[0], ':p:h')
  endif

  return printf('%s %s %s', self.cmd, self.cmd_args, l:target)
endfunction

function! s:mypy.file_command(file) abort
  return printf('%s %s %s', self.cmd, self.cmd_args, a:file)
endfunction

function! s:mypy.parse(item) abort
  return defx_lint#utils#parse_unix(a:item, v:true)
endfunction

call defx_lint#add_linter(s:mypy.new())
