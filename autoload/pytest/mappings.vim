" Keys in test files: an action prefix followed by a scope suffix, e.g.
" <localleader>rm runs the test method around the cursor.
let s:actions = {
      \ 'r': 'RunPytestScope',
      \ 't': 'RunPytestScopeTrace',
      \ 'd': 'RunPytestScopeTrace!',
      \ 'y': 'YankTest',
      \ }
let s:scopes = {'m': 'method', 'c': 'class', 'f': 'function', 't': 'file'}

" Buffer-local keys, in the project's test files only
function! pytest#mappings#apply() abort
  if !project_detect#is_test()
    return
  endif
  for [l:action, l:command] in items(s:actions)
    for [l:suffix, l:scope] in items(s:scopes)
      let l:rhs = l:command ==# 'YankTest'
            \ ? 'YankTest' . toupper(l:scope[0]) . l:scope[1:]
            \ : l:command . ' ' . l:scope
      execute printf('nnoremap <buffer> <silent> <localleader>%s%s <Cmd>%s<CR>', l:action, l:suffix, l:rhs)
    endfor
  endfor
endfunction
