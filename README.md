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

No keys are bound. These `<Plug>` mappings are provided for your vimrc, where
`{scope}` is `method`, `class`, `function` or `file`:

| Mapping | Action |
| --- | --- |
| `<Plug>(pytest-run-{scope})` | Run the test around the cursor |
| `<Plug>(pytest-trace-{scope})` | Same with `--trace` |
| `<Plug>(pytest-pdb-{scope})` | Same with `--pdb` |
| `<Plug>(pytest-yank-{scope})` | Yank the node id |

For example, in `~/.vim/ftplugin/python/keymaps.vim`, for test files only:

```vim
if expand('%:t') =~# '^test_'
  nmap <buffer> <localleader>rm <Plug>(pytest-run-method)
  nmap <buffer> <localleader>tm <Plug>(pytest-trace-method)
  nmap <buffer> <localleader>dm <Plug>(pytest-pdb-method)
  nmap <buffer> <localleader>ym <Plug>(pytest-yank-method)
  " ...and the same for class, function and file
endif
```

[dispatch-extras](https://github.com/roumail/dispatch-extras) adds `<Plug>`
mappings to repeat the last `:Dispatch` / `:Start`, open the last log and toggle
the `:Start` strategy.

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

Requires [vim-dispatch](https://github.com/tpope/vim-dispatch).
If a required plugin is missing, Vim shows
`pytest.vim: not loaded, requires …` at startup and the plugin defines nothing.

```vim
Plug 'tpope/vim-dispatch'
Plug 'roumail/pytest.vim'
```
