# pytest.vim

Run and debug pytest targets from Python buffers, through
[vim-dispatch](https://github.com/tpope/vim-dispatch).

Python buffers get `compiler pytest` and `b:dispatch`, so a plain `:Dispatch`
runs pytest too.

| Command (Python buffers) | What it does |
| --- | --- |
| `:RunPytest[!] [args]` | `:Dispatch` pytest with the given arguments (`!`: in the background). Its failures land in the quickfix list. |
| `:TracePytest [args]` | Run in a terminal with `--trace`. With project-detect. |

| Command (anywhere) | What it does |
| --- | --- |
| `:PytestTests` | The project's tests in the quickfix list, titled `Tests`, one entry per test. Run it again to refresh: it replaces its list, so `:colder` history isn't used up. With project-detect. |
| `:PytestOutline` | The current file's tests in the window's location list: its outline. |

`:ParsePytestFailures` (any buffer) reduces pasted pytest output, in the
buffer or a range of it, to one line per test, grouped into blocks per file
(`:ParsePytestFailures!`: per test class).

## Keys

With project-detect, test files get buffer-local keys: an action prefix
followed by a scope suffix.

| Prefix | Action |
| --- | --- |
| `<localleader>r` | Run the test around the cursor (`:Dispatch`) |
| `<localleader>t` | Same in a terminal with `--trace` |

| Suffix | Scope |
| --- | --- |
| `m` | method |
| `c` | class |
| `f` | function |
| `t` | file |

With `maplocalleader` set to `_`, `_rm` runs the test method around the cursor
and `_tf` debugs the test function with `--trace`. Where the line has no such
scope (`_rf` in a method, say), it says `Could not determine test path for
scope: function` and runs nothing.

The same keys work in the window of a test list (`:PytestTests`,
`:PytestOutline`), on the entry under the cursor, doing what they do in its
file with the cursor on its line: `_rm` runs that test (`_rf` when it is a
function), `_rc` its class, `_rt` its file. In other list windows they do
nothing of pytest.vim's. `<CR>`, and
[qf-tools](https://github.com/vimoured/qf-tools)' `dd` and `u`, work as in any
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
Nothing is stored. A list is what the files were when it was made: after a
checkout or edits, the keys still find an entry's test where it is now, and
say so when it is gone, but `<CR>` jumps to where it was. Run the command
again to refresh it. A run's results become the current quickfix list:
`:colder` goes back to the test list.

The test files, here and in `:PytestTests`, are those of the project
[project-detect](https://github.com/vimoured/project-detect) finds: files in its
`tests/` or `test/` directory, and the files pytest collects (`test_*.py`,
`*_test.py`). Outside a project, `:PytestTests` says `PytestTests: no project
here (project-detect)`.

[dispatch-extras](https://github.com/vimoured/dispatch-extras) adds `<Plug>`
mappings to repeat the last `:Dispatch` / `:Start`, open the last log and toggle
the `:Start` strategy.

## Test command

`:RunPytest` and the `r` keys run `:Dispatch` with pytest.vim's `pytest`
compiler, whose command is project-detect's Python `run` command (default
`pytest`). The `--trace` sessions run project-detect's
Python `debug` command, which defaults to its `run` command, `pytest`. For
example, to debug through a wrapper script:

```vim
let g:project_detect_runners = {
      \ 'python': {'debug': 'chkpyt.sh --no-default-addopts'},
      \ }
```

## Install

The core is pytest.vim and
[vim-dispatch](https://github.com/tpope/vim-dispatch), which runs the tests:

```vim
Plug 'tpope/vim-dispatch'
Plug 'vimoured/pytest.vim'
```

That gives Python buffers `:RunPytest` and `b:dispatch`, and every buffer
`:PytestOutline` and `:ParsePytestFailures`, with the keys in
`:PytestOutline`'s list.

Each row below adds a module on top of the core, and **Needs** is the whole
set of plugins it takes besides the core:

| Needs | Module | Adds |
| --- | --- | --- |
| [project-detect](https://github.com/vimoured/project-detect) | The project | The keys in its test files; `:PytestTests`, its tests; the `--trace` sessions, `:TracePytest` and the `t` keys, with its `debug` command; without it they say so |
| [qf-tools](https://github.com/vimoured/qf-tools) | Pruning lists | `dd` and `u` in `:PytestTests` and `:PytestOutline`, to keep the tests you're working on; `:QfSave` and `:QfLoad` to keep a pruned `:PytestTests` list across rebuilds, by name with vim-place |

The `--trace` sessions always run in a Vim terminal, whatever
`g:dispatch_no_tmux_start` (dispatch-extras' toggle) says (*not yet*: inside
tmux with it off, they open a tmux window: vim-dispatch has no
`-strategy=terminal`); no global vim-dispatch setting is changed.

*Not yet* marks a known bug: [vim-suite](https://github.com/vimoured/vim-suite)
asserts the behaviour described (its `test/known-failures.txt`), and the note
goes once it's fixed.

All of it:

```vim
Plug 'tpope/vim-dispatch'
Plug 'vimoured/project-detect'
Plug 'vimoured/qf-tools'
Plug 'vimoured/pytest.vim'
```

## Tests

Tested by [vim-suite](https://github.com/vimoured/vim-suite), in
`test/pytest.vim` and `test/pytest-outside-a-project.vim`, with the
dotfiles that use it: real pytest runs through vim-dispatch, and real
`--trace` terminals. Every pull request runs them.
