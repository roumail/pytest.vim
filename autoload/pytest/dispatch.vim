" -- needs to be added after dispatch, even if we automatically add -compiler pytest
"https://github.com/tpope/vim-dispatch/issues/263
function! pytest#dispatch#Dispatch(bang, args) abort
  execute 'Dispatch' . a:bang . ' -compiler=pytest -- ' . a:args
endfunction

function! pytest#dispatch#StartPytest(args) abort
  if !pytest#requires('A --trace session', 'project-detect', 'project_detect')
    return
  endif
  " --trace sessions run with the Python runner's debug command
  let l:cmd = project_detect#runner('python').debug
  execute 'Start! -strategy=terminal ' . l:cmd . ' ' . a:args
endfunction
