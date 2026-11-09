" pytest: run, --trace and --pdb pytest targets from Python buffers.
" Requires tpope/vim-dispatch; project-detect adds the keys in test files,
" :PytestTests and the --trace / --pdb sessions (README: Install).
" Reduce pytest output (or coverage test contexts) in the range (default: the
" buffer) to one line per test (! groups by test class, see
" pytest#failures#Parse)
command! -bang -range=% ParsePytestFailures call pytest#failures#Parse(<bang>0, <line1>, <line2>)

" The project's tests in the quickfix list, the current file's in the
" location list (its outline): the keys of test files work on their entries
command! -bar PytestTests call pytest#list#tests()
command! -bar PytestOutline call pytest#list#outline()

augroup pytest_lists
  autocmd!
  autocmd FileType qf call pytest#mappings#list()
augroup END
