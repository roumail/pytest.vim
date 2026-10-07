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
`Tapi_PdbDiff` is a terminal-API hook (`:h terminal-api`) that a pdb `vdiff`
command can call to show expected | actual in a diff tab.

| Keys (`test_*.py` buffers) | Action |
| --- | --- |
| `<localleader>r` + `m` `c` `f` `t` | Run method / class / function / file |
| `<localleader>t` + `m` `c` `f` `t` | Same with `--trace` |
| `<localleader>d` + `m` `c` `f` `t` | Same with `--pdb` |
| `<localleader>y` + `m` `c` `f` `F` | Yank method / class / function / file node id |
| `<localleader>rd`, `<localleader>rs` | With dispatch-extras: repeat the last `:Dispatch` / `:Start` |
| `<localleader>dl`, `<localleader>cs` | With dispatch-extras: open the last log / toggle the `:Start` strategy |

`let g:pytest_no_mappings = 1` skips them.

## Options

| Variable | Default | Used for |
| --- | --- | --- |
| `g:pytest_command` | `'pytest'` | Running tests (`:RunPytest`, `:RunPytestScope`, `:Dispatch`) |
| `g:pytest_debug_command` | `g:pytest_command` | `--trace` / `--pdb` sessions in a terminal |

For example, to run tests through a wrapper script:

```vim
let g:pytest_command = 'chkpyt.sh'
let g:pytest_debug_command = 'chkpyt.sh --no-default-addopts'
```

## Install

Requires vim-dispatch.
[dispatch-extras](https://github.com/roumail/dispatch-extras) is optional and adds
the repeat / log / strategy mappings.

```vim
Plug 'tpope/vim-dispatch'
Plug 'roumail/dispatch-extras'   " optional
Plug 'roumail/pytest.vim'
```
