" Whether the plugin with the autoload file autoload/{name}.vim is installed,
" saying what needs it when it isn't: the commands that use one check first
function! pytest#requires(what, plugin, name) abort
  if !empty(globpath(&runtimepath, 'autoload/' . a:name . '.vim', 1))
    return 1
  endif
  echohl ErrorMsg
  echomsg 'pytest.vim: ' . a:what . ' needs ' . a:plugin . ', which is not installed'
  echohl None
  return 0
endfunction

" One way to act on a test, from the cursor in a test file or from an entry
" of a test list: the scope gives a node id, the action is done on it.

" Does action on the test scope ('method', 'class', 'function', 'file')
" around the cursor, or, in a test list's window, around the entry under
" the cursor. bang: :Dispatch! for 'run'.
function! pytest#act(action, scope, ...) abort
  let [l:nodeid, l:error] = pytest#list#in_list() ? pytest#list#nodeid(a:scope)
        \ : [pytest#nodeid(a:scope), 'Could not determine test path for scope: ' . a:scope]
  if empty(l:nodeid)
    echo l:error
    return
  endif
  call pytest#run(a:action, l:nodeid, get(a:, 1, ''))
endfunction

" The node id of the scope around the cursor, '' when there is none
function! pytest#nodeid(scope) abort
  return pytest#scan#nodeid(a:scope, pytest#scan#path(expand('%')), getline(1, '$'), line('.'))
endfunction

" action: 'run' (:Dispatch, bang: :Dispatch!), 'trace' (--trace in a
" terminal), 'debug' (--pdb in a terminal) or 'yank' (the node id to the
" clipboard and the unnamed register)
function! pytest#run(action, nodeid, ...) abort
  if a:action ==# 'run'
    call pytest#dispatch#Dispatch(get(a:, 1, ''), a:nodeid)
  elseif a:action ==# 'trace' || a:action ==# 'debug'
    call pytest#dispatch#StartPytest(a:nodeid . (a:action ==# 'trace' ? ' --trace' : ' --pdb'))
  elseif a:action ==# 'yank'
    let @+ = a:nodeid
    let @" = a:nodeid
    echo 'Copied: ' . a:nodeid
  endif
endfunction
