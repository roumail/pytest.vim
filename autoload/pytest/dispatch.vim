" -- needs to be added after dispatch, even if we automatically add -compiler pytest
"https://github.com/tpope/vim-dispatch/issues/263
" Previously we had to explicitly pass -compiler=pytest -- <args>
" This is handled via b:dispatch
function! pytest#dispatch#Dispatch(bang, args) abort
  execute 'Dispatch' . a:bang . ' -compiler=pytest -- ' . a:args
endfunction

function! pytest#dispatch#StartPytest(args) abort
  " --trace / --pdb sessions run with the Python runner's debug command
  let l:cmd = project_detect#runner('python').debug
  execute 'Start! -strategy=terminal ' . l:cmd . ' ' . a:args
endfunction

function! pytest#dispatch#WithScope(scope, bang) abort
  let test_path = pytest#common#GetTestPath(a:scope)

  if empty(test_path)
    echo "Could not determine test path for scope: " . a:scope
    return
  endif

  call pytest#dispatch#Dispatch(a:bang, test_path)
endfunction


" Helper function to run pytest with trace in terminal
function! pytest#dispatch#WithScopeAndTrace(scope, bang) abort
  let test_path = pytest#common#GetTestPath(a:scope)

  if empty(test_path)
    echo "Could not determine test path for scope: " . a:scope
    return
  endif

  let debug_flag = empty(a:bang) ? '--trace' : '--pdb'
  call pytest#dispatch#StartPytest(test_path . ' ' . debug_flag)
endfunction
