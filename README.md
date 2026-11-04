# pytest.vim

Run, debug and yank pytest targets from Python buffers, through
[vim-dispatch](https://github.com/tpope/vim-dispatch).

Python buffers get `compiler pytest` and `b:dispatch`, so a plain `:Dispatch`
runs pytest too.

| Command (Python buffers) | What it does |
| --- | --- |
| `:RunPytest[!] [args]` | `:Dispatch` pytest with the given arguments. |
| `:RunPytestScope[!] {method\|class\|function\|file}` | Run the test around the cursor. |
| `:RunPytestScopeTrace[!] {scope}` | Same, in a terminal with `--trace` (`!`: `--pdb`). |
| `:TracePytest [args]` | Run in a terminal with `--trace`. |
| `:YankTestMethod`, `:YankTestClass`, `:YankTestFunction`, `:YankTestFile` | Copy the pytest node id. |

| Command (anywhere) | What it does |
| --- | --- |
| `:PytestTests` | The project's tests in the quickfix list, titled `Tests`, one entry per test. Run it again to refresh: it replaces its list, so `:colder` history isn't used up. |
| `:PytestOutline` | The current file's tests in the window's location list: its outline. |

`:ParsePytestFailures` (any buffer) reduces pasted pytest output, in the
buffer or a range of it, to one line per test, grouped into blocks per file
(`:ParsePytestFailures!`: per test class).

## Keys

Test files get buffer-local keys: an action prefix followed by a scope suffix.

| Prefix | Action |
| --- | --- |
| `<localleader>r` | Run the test around the cursor |
| `<localleader>t` | Same in a terminal with `--trace` |
| `<localleader>d` | Same in a terminal with `--pdb` |
| `<localleader>y` | Yank the node id |

| Suffix | Scope |
| --- | --- |
| `m` | method |
| `c` | class |
| `f` | function |
| `t` | file |

With `maplocalleader` set to `_`, `_rm` runs the test method around the cursor
and `_yf` yanks the test function's node id.

The same keys work in the window of a test list (`:PytestTests`,
`:PytestOutline`), on the entry under the cursor, doing what they do in its
file with the cursor on its line: `_rm` runs that test (`_rf` when it is a
function), `_rc` its class, `_rt` its file. In other list windows they do
nothing of pytest.vim's. `<CR>`, and
[qf-tools](https://github.com/roumail/qf-tools)' `dd` and `u`, work as in any
list. Set `maplocalleader` in your vimrc, not in an ftplugin, so the list
windows get it too.

A test is what pytest collects by default, found without running pytest:
module-level `test*` functions and the `test*` methods of module-level
`Test*` classes. A parametrised test is one entry. The scopes around a line:

| Scope | Is |
| --- | --- |
| function | The module-level `test*` function the line is in |
| class | The module-level class the line is in |
| method | The method of that class the line is in (a function nested in it is part of it) |
| file | The file |

The lists read a file's buffer when it is loaded, so unsaved edits count.
Nothing is stored.

The test files, here and in `:PytestTests`, are those of the project
[project-detect](https://github.com/roumail/project-detect) finds: files in its
`tests/` or `test/` directory, and the files pytest collects (`test_*.py`,
`*_test.py`).

[dispatch-extras](https://github.com/roumail/dispatch-extras) adds `<Plug>`
mappings to repeat the last `:Dispatch` / `:Start`, open the last log and toggle
the `:Start` strategy.

## Test command

Tests run with project-detect's Python runner: `pytest`, or the command you set
for Python in `g:project_detect_runners`. `debug` runs the `--trace` / `--pdb`
sessions and defaults to `run`. For example, to run tests through a wrapper
script:

```vim
let g:project_detect_runners = {
      \ 'python': {'run': 'chkpyt.sh', 'debug': 'chkpyt.sh --no-default-addopts'},
      \ }
```

## Install

Requires [vim-dispatch](https://github.com/tpope/vim-dispatch) and
[project-detect](https://github.com/roumail/project-detect). With
[vim-requires](https://github.com/roumail/vim-requires), Vim shows
`pytest.vim: requires …` at startup when one isn't loaded.
`:ParsePytestFailures` works on its own.

`:TracePytest` and the `trace` / `pdb` actions always run in a Vim terminal
(`:Start -strategy=terminal`); no global vim-dispatch setting is changed.

```vim
Plug 'tpope/vim-dispatch'
Plug 'roumail/project-detect'
Plug 'roumail/vim-requires'  " optional: the startup warning
Plug 'roumail/pytest.vim'
```

## Tests

```sh
vim -Nu NONE -i NONE -Es -S test/run.vim
```

project-detect comes from `$PROJECT_DETECT`, else vim-plug's copy.
