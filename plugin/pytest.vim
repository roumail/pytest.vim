" pytest: run, debug and yank pytest targets from Python buffers.
" Requires tpope/vim-dispatch and roumail/project-detect. Tests run with
" project-detect's Python runner.
if exists('g:loaded_pytest_tools')
  finish
endif
let g:loaded_pytest_tools = 1

" Warns at startup when a required plugin isn't loaded (roumail/vim-requires)
try
  call roumail_requires#check('pytest.vim', {
        \ 'tpope/vim-dispatch': 'g:loaded_dispatch',
        \ 'roumail/project-detect': 'g:loaded_project_detect',
        \ })
catch /^Vim\%((\a\+)\)\=:E117:/
endtry

" Reduce pytest output (or coverage test contexts) in the current buffer to
" one line per test (! groups by test class, see pytest#failures#Parse)
command! -bang ParsePytestFailures call pytest#failures#Parse(<bang>0)
