" pytest: run, debug and yank pytest targets from Python buffers.
" Requires tpope/vim-dispatch. g:pytest_command / g:pytest_debug_command replace
" pytest (see README); the repeat / log / strategy mappings are added when
" dispatch-extras is installed.
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
