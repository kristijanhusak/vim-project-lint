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
        self.cache = {}

    def get(self, context: Context, candidate: dict) -> str:
        path = str(candidate['action__path'])
        default = self.format('')
        if candidate.get('is_root', False):
            self.vim.call('defx_lint#exec', path)
            return default

        data = self.vim.vars['defx_lint#data']
        if not data:
            return default

        if path in self.cache:
            return self.format('x' if self.cache[path] else '')

        entry = self.find_in_data(data, candidate)

        if not entry:
            self.cache[path] = False
            return default

        self.cache[path] = True
        return self.format('x')

    def length(self, context: Context) -> int:
        return self.column_length

    def find_in_data(self, data, candidate: dict) -> str:
        path = str(candidate['action__path'])
        path += '/' if candidate['is_directory'] else ''
        for item in data:
            if item.startswith(path):
                return item

        return ''

    def format(self, column: str) -> str:
        return format(column, f'<{self.column_length}')
