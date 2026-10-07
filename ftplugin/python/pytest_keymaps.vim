if exists('b:loaded_python_pytest_keymaps_ftplugin')
  finish
endif
let b:loaded_python_pytest_keymaps_ftplugin = 1

" Set g:pytest_no_mappings = 1 to define your own mappings instead
if get(g:, 'pytest_no_mappings', 0) || expand('%:t') !~ '^test_'
  finish
endif

" The dispatch-extras mappings are only added when that plugin is installed
let s:extras = !empty(maparg('<Plug>(dispatch-extras-log)', 'n'))

if s:extras
  " Open log of last dispatch run as a buffer
  nmap <buffer> <localleader>dl <Plug>(dispatch-extras-log)
  " Switch b/w tmux and terminal running strategy for Start (used for debugging)
  nmap <buffer> <localleader>cs <Plug>(dispatch-extras-toggle-start-strategy)
endif
nnoremap <buffer> <localleader>rm :RunPytestScope method<CR>
nnoremap <buffer> <localleader>rc :RunPytestScope class<CR>
nnoremap <buffer> <localleader>rf :RunPytestScope function<CR>
nnoremap <buffer> <localleader>rt :RunPytestScope file<CR>

" Run with --pdb in terminal
nnoremap <buffer> <localleader>dm :RunPytestScopeTrace! method<CR>
nnoremap <buffer> <localleader>dc :RunPytestScopeTrace! class<CR>
nnoremap <buffer> <localleader>df :RunPytestScopeTrace! function<CR>
nnoremap <buffer> <localleader>dt :RunPytestScopeTrace! file<CR>

" Run with --trace in terminal
nnoremap <buffer> <localleader>tm :RunPytestScopeTrace method<CR>
nnoremap <buffer> <localleader>tc :RunPytestScopeTrace class<CR>
nnoremap <buffer> <localleader>tf :RunPytestScopeTrace function<CR>
nnoremap <buffer> <localleader>tt :RunPytestScopeTrace file<CR>

if s:extras
  " rerun last start command (debug)
  nmap <buffer> <localleader>rs <Plug>(dispatch-extras-repeat-start)
  " rerun last dispatch command (run)
  nmap <buffer> <localleader>rd <Plug>(dispatch-extras-repeat-dispatch)
endif

" Yank test paths
nnoremap <buffer> <localleader>ym :YankTestMethod<CR>
nnoremap <buffer> <localleader>yc :YankTestClass<CR>
nnoremap <buffer> <localleader>yf :YankTestFunction<CR>
nnoremap <buffer> <localleader>yF :YankTestFile<CR>
