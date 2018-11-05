# ============================================================================
# FILE: git.py
# AUTHOR: Kristijan Husak <husakkristijan at gmail.com>
# License: MIT license
# ============================================================================

import typing
from defx.base.column import Base
from defx.context import Context
from neovim import Nvim


class Column(Base):

    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)
        self.name = 'project_lint'
        self.column_length = 2
        self.icon: str = self.vim.vars['project_lint#icon']
        self.color: str = self.vim.vars['project_lint#icon_color']
        self.cache: typing.Dict[str, dict] = {}

    def get(self, context: Context, candidate: dict) -> str:
        default: str = self.format('')
        if candidate.get('is_root', False):
            self.cache = self.vim.call('project_lint#get_data')
            return default

        if not self.cache:
            return default

        path = str(candidate['action__path'])
        if path in self.cache:
            return self.format(self.icon)

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
