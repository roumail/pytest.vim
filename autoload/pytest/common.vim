" The node id of the scope around the cursor (see pytest#scan#nodeid)
function! pytest#common#GetTestPath(scope) abort
  return pytest#nodeid(a:scope)
endfunction

function! pytest#common#YankTestPath(scope) abort
  call pytest#act('yank', a:scope)
endfunction
