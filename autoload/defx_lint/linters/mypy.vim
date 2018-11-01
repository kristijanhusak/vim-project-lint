let s:mypy = {}

function! s:mypy.New() abort
  let l:instance = copy(self)
  let l:instance.name = 'mypy'
  let l:instance.cmd = ''
  let l:instance.cmd_args = get(g:, 'defx_lint#linter_args.mypy', '')
  let l:instance.stream = 'stdout'
  let l:instance.filetype = ['python']
  return l:instance
endfunction

function! s:mypy.Detect() abort
  let self.files = defx_lint#utils#find_extension('py')
  return len(self.files) > 0 && self.Executable()
endfunction

function! s:mypy.DetectForFile() abort
  return index(self.filetype, &filetype) > -1
endfunction

function! s:mypy.Executable() abort
  if executable('mypy')
    let self.cmd = 'mypy'
    return v:true
  endif

  return v:false
endfunction

function! s:mypy.Cmd() abort
  if self.cmd ==? ''
    return ''
  endif

  let l:target = '.'
  if len(self.files) > 0
    let l:target = fnamemodify(self.files[0], ':p:h')
  endif

  return printf('%s %s %s', self.cmd, self.cmd_args, l:target)
endfunction

function! s:mypy.FileCmd(file) abort
  if self.cmd ==? ''
    return ''
  endif

  return printf('%s %s', self.cmd, a:file)
endfunction

function! s:mypy.Parse(item) abort
  return defx_lint#utils#parse_unix(a:item, v:true)
endfunction

call defx_lint#add_linter(s:mypy.New())
