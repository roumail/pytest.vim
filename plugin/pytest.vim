" pytest: run, debug and yank pytest targets from Python buffers.
" Requires tpope/vim-dispatch. g:pytest_command / g:pytest_debug_command replace
" pytest (see README).
if exists('g:loaded_pytest_tools')
  finish
endif
" Required plugins: without them nothing here is defined
let s:missing = filter({
      \ 'tpope/vim-dispatch': 'autoload/dispatch.vim',
      \ }, 'empty(globpath(&rtp, v:val))')
if !empty(s:missing)
  echohl WarningMsg
  echomsg 'pytest.vim: not loaded, requires ' . join(sort(keys(s:missing)), ', ')
  echohl None
  finish
endif
unlet s:missing
let g:loaded_pytest_tools = 1

" File names (globs) that count as test files: they get the g:pytest_mappings
" keys. Defaults to pytest's own python_files.
let g:pytest_file_patterns = get(g:, 'pytest_file_patterns', ['test_*.py', '*_test.py'])

" Reduce pytest output (or coverage test contexts) in the current buffer to
" one line per test (! groups by test class, see pytest#failures#Parse)
command! -bang ParsePytestFailures call pytest#failures#Parse(<bang>0)

" <Plug> mappings. Test files get keys for them when g:pytest_mappings is set
" (see README). They call the buffer-local commands from
" ftplugin/python/pytest.vim, so they work in Python buffers.
" Run the method / class / function / file around the cursor
nnoremap <silent> <Plug>(pytest-run-method) <Cmd>RunPytestScope method<CR>
nnoremap <silent> <Plug>(pytest-run-class) <Cmd>RunPytestScope class<CR>
nnoremap <silent> <Plug>(pytest-run-function) <Cmd>RunPytestScope function<CR>
nnoremap <silent> <Plug>(pytest-run-file) <Cmd>RunPytestScope file<CR>
" Same in a terminal with --trace
nnoremap <silent> <Plug>(pytest-trace-method) <Cmd>RunPytestScopeTrace method<CR>
nnoremap <silent> <Plug>(pytest-trace-class) <Cmd>RunPytestScopeTrace class<CR>
nnoremap <silent> <Plug>(pytest-trace-function) <Cmd>RunPytestScopeTrace function<CR>
nnoremap <silent> <Plug>(pytest-trace-file) <Cmd>RunPytestScopeTrace file<CR>
" Same in a terminal with --pdb
nnoremap <silent> <Plug>(pytest-pdb-method) <Cmd>RunPytestScopeTrace! method<CR>
nnoremap <silent> <Plug>(pytest-pdb-class) <Cmd>RunPytestScopeTrace! class<CR>
nnoremap <silent> <Plug>(pytest-pdb-function) <Cmd>RunPytestScopeTrace! function<CR>
nnoremap <silent> <Plug>(pytest-pdb-file) <Cmd>RunPytestScopeTrace! file<CR>
" Yank the pytest node id
nnoremap <silent> <Plug>(pytest-yank-method) <Cmd>YankTestMethod<CR>
nnoremap <silent> <Plug>(pytest-yank-class) <Cmd>YankTestClass<CR>
nnoremap <silent> <Plug>(pytest-yank-function) <Cmd>YankTestFunction<CR>
nnoremap <silent> <Plug>(pytest-yank-file) <Cmd>YankTestFile<CR>
