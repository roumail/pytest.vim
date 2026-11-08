# pytest.vim

Run and debug pytest targets from Python buffers, through
[vim-dispatch](https://github.com/tpope/vim-dispatch), with keys for the test
around the cursor and lists of a project's tests.

**Vim or Neovim:** tested on Vim 9.1 and newer. It's plain Vimscript, so it may
work on Neovim, but that's untested.

## Install

```vim
Plug 'tpope/vim-dispatch'
Plug 'vimoured/pytest.vim'
```

Optional, each for what it adds:

| Also needs | Adds |
| --- | --- |
| [project-detect](https://github.com/vimoured/project-detect) | The keys in test files, `:PytestTests`, and the `--trace` sessions |
| [qf-tools](https://github.com/vimoured/qf-tools) | `dd` and `u` in the test lists, and saving a pruned list |

## Use

| Command | Where | What it does |
| --- | --- | --- |
| `:RunPytest[!] [args]` | Python buffers | `:Dispatch` pytest; `!` runs it in the background. |
| `:TracePytest [args]` | Python buffers | Run with `--trace` in a Vim terminal. |
| `:PytestTests` | Anywhere | The project's tests in the quickfix list. |
| `:PytestOutline` | Anywhere | The current file's tests in the location list. |
| `:ParsePytestFailures[!]` | Anywhere | Reduce pasted pytest output to one line per test, grouped by file (`!`: by class). |

With project-detect, test files and the test lists get buffer-local keys: an
action followed by a scope.

| Keys | Action | | Key | Scope |
| --- | --- | --- | --- | --- |
| `<localleader>r` | Run with `:Dispatch` | | `m` | method |
| `<localleader>t` | Run with `--trace` | | `c` | class |
| | | | `f` | function |
| | | | `t` | file |

With `maplocalleader` set to `_`, `_rm` runs the test method around the cursor.
Set `maplocalleader` in your vimrc, so the list windows get it too.

To run tests or debug through your own command, set project-detect's runners:

```vim
let g:project_detect_runners = {
      \ 'python': {'debug': 'chkpyt.sh --no-default-addopts'},
      \ }
```

## Tests

The specs in [vim-suite](https://github.com/vimoured/vim-suite) define what it
does: `test/pytest.vim` and `test/pytest-outside-a-project.vim`.
