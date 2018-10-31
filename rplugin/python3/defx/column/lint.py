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

    def get(self, context: Context, candidate: dict) -> str:
        default = self.format('')
        if candidate.get('is_root', False):
            return default

        nodes = set(self.vim.vars['defx_lint#nodes'])
        if not nodes:
            return default

        path = str(candidate['action__path'])
        cache = self.vim.vars['defx_lint#cache']

        if path in cache:
            return self.format('x' if cache[path] else '')

        entry = self.find_in_nodes(nodes, path, candidate['is_directory'])

        if not entry:
            self.vim.call('defx_lint#cache#put', path, False)
            return default

        self.vim.call('defx_lint#cache#put', path, True)
        return self.format('x')

    def length(self, context: Context) -> int:
        return self.column_length

    def find_in_nodes(self, data, path: str, is_dir: bool) -> str:
        path += '/' if is_dir else ''
        for item in data:
            if item.startswith(path):
                return item

        return ''

    def format(self, column: str) -> str:
        return format(column, f'<{self.column_length}')
