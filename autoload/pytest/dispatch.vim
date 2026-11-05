" -- needs to be added after dispatch, even if we automatically add -compiler pytest
"https://github.com/tpope/vim-dispatch/issues/263
function! pytest#dispatch#Dispatch(bang, args) abort
  execute 'Dispatch' . a:bang . ' -compiler=pytest -- ' . a:args
endfunction

function! pytest#dispatch#StartPytest(args) abort
  if !pytest#requires('A --trace / --pdb session', 'project-detect', 'project_detect')
    return
  endif
  " --trace / --pdb sessions run with the Python runner's debug command
  let l:cmd = project_detect#runner('python').debug
  execute 'Start! -strategy=terminal ' . l:cmd . ' ' . a:args
endfunction

function! pytest#dispatch#WithScope(scope, bang) abort
  call pytest#act('run', a:scope, a:bang)
endfunction

" --trace, or --pdb with bang
function! pytest#dispatch#WithScopeAndTrace(scope, bang) abort
  call pytest#act(empty(a:bang) ? 'trace' : 'debug', a:scope)
endfunction
