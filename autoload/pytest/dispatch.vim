" -- needs to be added after dispatch, even if we automatically add -compiler pytest
"https://github.com/tpope/vim-dispatch/issues/263
function! pytest#dispatch#Dispatch(bang, args) abort
  execute 'Dispatch' . a:bang . ' -compiler=pytest -- ' . a:args
endfunction

function! pytest#dispatch#StartPytest(args) abort
  if !pytest#requires('A --trace session', 'project-detect', 'project_detect')
    return
  endif
  let l:handlers = g:dispatch_handlers
  let g:dispatch_handlers = ['terminal']
  try
    execute 'Start! ' . project_detect#runner('python').debug . ' ' . a:args
  finally
    let g:dispatch_handlers = l:handlers
  endtry
endfunction
