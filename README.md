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

`:ParsePytestFailures` (any buffer) reduces pasted pytest output to one line per
test, grouped into blocks per file (`:ParsePytestFailures!`: per test class).

## Keys

Test files are the Python files whose name matches `g:pytest_file_patterns`
(pytest's own default: `test_*.py` and `*_test.py`); `pytest#is_test_file()`
tells whether the current buffer is one.

Nothing is bound until you set `g:pytest_mappings`. Then every test file gets
buffer-local keys: an action prefix followed by a scope suffix.

```vim
let g:pytest_mappings = {
      \ 'run': '<localleader>r',
      \ 'trace': '<localleader>t',
      \ 'pdb': '<localleader>d',
      \ 'yank': '<localleader>y',
      \ 'scopes': {'method': 'm', 'class': 'c', 'function': 'f', 'file': 't'},
      \ }
```

With `maplocalleader` set to `_`, `_rm` runs the test method around the cursor
and `_yf` yanks the test function's node id.

| Action | What it does |
| --- | --- |
| `run` | Run the test around the cursor |
| `trace` | Same in a terminal with `--trace` |
| `pdb` | Same in a terminal with `--pdb` |
| `yank` | Yank the node id |

- An `'<action>-<scope>'` entry sets that one key instead, e.g.
  `'yank-file': '<localleader>yF'`. An empty string leaves it unmapped.
- Leave an action or scope out to skip it.

## `<Plug>` mappings

For your own bindings, each key above is also a `<Plug>` mapping,
`<Plug>(pytest-{action}-{scope})`, e.g. `<Plug>(pytest-run-method)`. They call
the buffer-local commands, so they work in Python buffers.

[dispatch-extras](https://github.com/roumail/dispatch-extras) adds `<Plug>`
mappings to repeat the last `:Dispatch` / `:Start`, open the last log and toggle
the `:Start` strategy.

## Options

| Variable | Default | Used for |
| --- | --- | --- |
| `g:pytest_command` | `'pytest'` | Running tests (`:RunPytest`, `:RunPytestScope`, `:Dispatch`) |
| `g:pytest_debug_command` | `g:pytest_command` | `--trace` / `--pdb` sessions in a terminal |
| `g:pytest_file_patterns` | `['test_*.py', '*_test.py']` | Which files are test files (globs on the file name) |
| `g:pytest_mappings` | unset | Keys in test files (see [Keys](#keys)) |

For example, to run tests through a wrapper script:

```vim
let g:pytest_command = 'chkpyt.sh'
let g:pytest_debug_command = 'chkpyt.sh --no-default-addopts'
```

## Install

Requires [vim-dispatch](https://github.com/tpope/vim-dispatch).
If a required plugin is missing, Vim shows
`pytest.vim: not loaded, requires …` at startup and the plugin defines nothing.

```vim
Plug 'tpope/vim-dispatch'
Plug 'roumail/pytest.vim'
```
