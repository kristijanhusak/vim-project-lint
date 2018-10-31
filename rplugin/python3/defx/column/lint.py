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
        self.cwd = self.vim.call('getcwd')

    def get(self, context: Context, candidate: dict) -> str:
        path = str(candidate['action__path'])
        default = self.format('')
        if candidate.get('is_root', False):
            if path == self.cwd:
                self.vim.call('defx_lint#exec', path)
            return default

        data = set(self.vim.vars['defx_lint#data'])
        if not data:
            return default

        cache = self.vim.vars['defx_lint#cache']

        if path in cache:
            return self.format('x' if cache[path] else '')

        entry = self.find_in_data(data, path, candidate['is_directory'])

        if not entry:
            self.vim.call('defx_lint#cache_put', path, False)
            return default

        self.vim.call('defx_lint#cache_put', path, True)
        return self.format('x')

    def length(self, context: Context) -> int:
        return self.column_length

    def find_in_data(self, data, path: str, is_dir: bool) -> str:
        path += '/' if is_dir else ''
        for item in data:
            if item.startswith(path):
                return item

        return ''

    def format(self, column: str) -> str:
        return format(column, f'<{self.column_length}')
