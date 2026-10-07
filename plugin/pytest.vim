" pytest: run, debug and yank pytest targets from Python buffers.
" Requires tpope/vim-dispatch. g:pytest_command / g:pytest_debug_command replace
" pytest (see README).
if exists('g:loaded_pytest_tools')
  finish
endif
let g:loaded_pytest_tools = 1

" Reduce pytest output (or coverage test contexts) in the current buffer to
" one line per test (! groups by test class, see pytest#failures#Parse)
command! -bang ParsePytestFailures call pytest#failures#Parse(<bang>0)

" Called by pdb's `vdiff` (.pdbrc.py) from inside a :terminal via the terminal
" API (:h terminal-api). Shows expected | actual in a single reused tab, so
" gt/gT flips between the diff and the pdb terminal.
function! Tapi_PdbDiff(bufnr, files) abort
  let l:tab = 0
  for l:t in range(1, tabpagenr('$'))
    if gettabvar(l:t, 'pdb_diff', 0)
      let l:tab = l:t
      break
    endif
  endfor
  if l:tab
    execute l:tab . 'tabnext'
    diffoff!
    silent! only!
  else
    tabnew
    let t:pdb_diff = 1
  endif
  execute 'edit!' fnameescape(a:files[0])
  setlocal bufhidden=wipe
  execute 'rightbelow vertical diffsplit' fnameescape(a:files[1])
  setlocal bufhidden=wipe
endfunction

" <Plug> mappings; no keys are bound here (see README). They call the
" buffer-local commands from ftplugin/python/pytest.vim, so they work in Python
" buffers.
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
