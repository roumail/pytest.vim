" pytest: run, debug and yank pytest targets from Python buffers.
" Requires tpope/vim-dispatch and roumail/project-detect, checked in
" ftplugin/python/pytest.vim. Tests run with project-detect's Python runner.
if exists('g:loaded_pytest_tools')
  finish
endif
let g:loaded_pytest_tools = 1

" Reduce pytest output (or coverage test contexts) in the current buffer to
" one line per test (! groups by test class, see pytest#failures#Parse)
command! -bang ParsePytestFailures call pytest#failures#Parse(<bang>0)
