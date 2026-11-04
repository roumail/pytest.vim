" Keys: an action prefix followed by a scope suffix, e.g. <localleader>rm
" runs the test method around the cursor. The same keys in a test file and
" in a test list's window.
let s:actions = {'r': 'run', 't': 'trace', 'd': 'debug', 'y': 'yank'}
let s:scopes = {'m': 'method', 'c': 'class', 'f': 'function', 't': 'file'}

" In the project's test files
function! pytest#mappings#apply() abort
  if !project_detect#is_test()
    return
  endif
  for [l:a, l:action] in items(s:actions)
    for [l:s, l:scope] in items(s:scopes)
      execute printf('nnoremap <buffer> <silent> <localleader>%s%s <Cmd>call pytest#act(%s, %s)<CR>',
            \ l:a, l:s, string(l:action), string(l:scope))
    endfor
  endfor
endfunction

" In every list window, doing what they do in the entry's file when the
" list is a test list, else what the keys do without a mapping
function! pytest#mappings#list() abort
  for [l:a, l:action] in items(s:actions)
    for [l:s, l:scope] in items(s:scopes)
      execute printf('nnoremap <buffer> <silent> <expr> <localleader>%s%s pytest#mappings#key(%s, %s, %s)',
            \ l:a, l:s, string(l:action), string(l:scope), string(l:a . l:s))
    endfor
  endfor
endfunction

function! pytest#mappings#key(action, scope, keys) abort
  return pytest#list#in_list()
        \ ? printf("\<Cmd>call pytest#act(%s, %s)\<CR>", string(a:action), string(a:scope))
        \ : get(g:, 'maplocalleader', '\') . a:keys
endfunction
