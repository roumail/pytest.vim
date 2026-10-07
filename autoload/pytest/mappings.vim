let s:actions = ['run', 'trace', 'pdb', 'yank']
let s:scopes = ['method', 'class', 'function', 'file']

" The key for one action and scope from g:pytest_mappings: an '<action>-<scope>'
" entry if there is one, else the action's prefix plus the scope's suffix.
" '' leaves it unmapped.
function! s:key(keys, action, scope) abort
  let l:override = a:action . '-' . a:scope
  if has_key(a:keys, l:override)
    return a:keys[l:override]
  endif
  let l:suffixes = get(a:keys, 'scopes', {})
  if !has_key(a:keys, a:action) || !has_key(l:suffixes, a:scope)
    return ''
  endif
  return a:keys[a:action] . l:suffixes[a:scope]
endfunction

" Buffer-local keys from g:pytest_mappings, in test files only. Nothing when
" g:pytest_mappings isn't set.
function! pytest#mappings#apply() abort
  let l:keys = get(g:, 'pytest_mappings', {})
  if empty(l:keys) || !pytest#is_test_file()
    return
  endif
  for l:action in s:actions
    for l:scope in s:scopes
      let l:lhs = s:key(l:keys, l:action, l:scope)
      if !empty(l:lhs)
        execute 'nmap <buffer>' l:lhs printf('<Plug>(pytest-%s-%s)', l:action, l:scope)
      endif
    endfor
  endfor
endfunction
