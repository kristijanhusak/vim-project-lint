# ============================================================================
# FILE: git.py
# AUTHOR: Kristijan Husak <husakkristijan at gmail.com>
# License: MIT license
# ============================================================================

from defx.base.column import Base
from defx.context import Context
from neovim import Nvim


class Column(Base):

    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)
        self.name = 'lint'
        self.column_length = 2
        self.icon = '✗'
        self.color = 'guifg=#fb4934 ctermfg=167'

    def get(self, context: Context, candidate: dict) -> str:
        default = self.format('')
        status = self.vim.vars['defx_lint#status']
        if status['running'] or candidate.get('is_root', False):
            return default

        cache = self.vim.vars['defx_lint#cache']
        if not cache:
            return default

        path = str(candidate['action__path'])
        if path in cache:
            return self.format(self.icon if cache[path] else '')

        return default

    def length(self, context: Context) -> int:
        return self.column_length

    def format(self, column: str) -> str:
        return format(column, f'<{self.column_length}')

    def highlight(self) -> None:
        self.vim.command(('syntax match {0}_{1} /[{2}]/ ' +
                          'contained containedin={0}').format(
                              self.syntax_name, self.name, self.icon
                          ))
        self.vim.command('highlight default {0}_{1} {2}'.format(
            self.syntax_name, self.name, self.color
        ))
