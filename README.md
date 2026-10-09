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

The test files are those of the project
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
[project-detect](https://github.com/roumail/project-detect). Without them, the
first Python buffer shows `pytest.vim: requires …` and Python buffers get no
pytest commands or keys. `:ParsePytestFailures` works on its own.

`:TracePytest` and the `trace` / `pdb` actions always run in a Vim terminal
(`:Start -strategy=terminal`); no global vim-dispatch setting is changed.

```vim
Plug 'tpope/vim-dispatch'
Plug 'roumail/project-detect'
Plug 'roumail/pytest.vim'
```
