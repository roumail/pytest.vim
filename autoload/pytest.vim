" Whether a buffer (default: the current one) is a test file: its file name
" matches one of the g:pytest_file_patterns globs
function! pytest#is_test_file(...) abort
  let l:name = fnamemodify(bufname(a:0 ? a:1 : '%'), ':t')
  for l:pattern in g:pytest_file_patterns
    if l:name =~# glob2regpat(l:pattern)
      return 1
    endif
  endfor
  return 0
endfunction
