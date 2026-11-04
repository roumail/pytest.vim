" The test lists: the project's tests in the quickfix list ('Tests') and a
" file's in the window's location list (its outline). Their context marks
" them as pytest.vim's, for the keys in their window.

let s:title = 'Tests'

" :PytestTests: the tests of the project's test files (project-detect's),
" in the quickfix list, replacing an earlier one
function! pytest#list#tests() abort
  let l:root = project_detect#root()
  if empty(l:root)
    echo 'PytestTests: no project here (project-detect)'
    return
  endif
  let l:items = []
  for l:file in s:test_files(l:root)
    call extend(l:items, pytest#scan#tests(pytest#scan#path(l:file), pytest#scan#lines(l:file)))
  endfor
  let l:what = {'title': s:title, 'items': l:items, 'context': {'pytest': 'tests'}}
  let l:id = s:find_id()
  if l:id
    call setqflist([], 'r', extend(l:what, {'id': l:id}))
    " Make it the current list, as a new one would be
    let l:moves = getqflist({'nr': 0}).nr - getqflist({'id': l:id, 'nr': 0}).nr
    if l:moves
      execute 'silent' abs(l:moves) . (l:moves > 0 ? 'colder' : 'cnewer')
    endif
  else
    call setqflist([], ' ', l:what)
  endif
  copen
  echo s:title . ': ' . len(l:items)
endfunction

" :PytestOutline: the tests of the current file, in the window's location
" list
function! pytest#list#outline() abort
  let l:path = pytest#scan#path(expand('%'))
  let l:items = pytest#scan#tests(l:path, getline(1, '$'))
  let l:what = {'title': s:title . ': ' . l:path, 'items': l:items,
        \ 'context': {'pytest': 'outline'}}
  " Replaces the window's outline, so :lolder goes back past it
  let l:context = getloclist(0, {'context': 0}).context
  call setloclist(0, [], type(l:context) == v:t_dict && has_key(l:context, 'pytest') ? 'r' : ' ', l:what)
  lopen
  echo s:title . ': ' . len(l:items) . ' in ' . l:path
endfunction

" The project's Python files that are its tests, absolute
function! s:test_files(root) abort
  let l:files = systemlist('git -C ' . shellescape(a:root)
        \ . ' ls-files --cached --others --exclude-standard -- ''*.py''')
  if v:shell_error
    let l:files = map(globpath(a:root, '**/*.py', 1, 1), 'v:val[len(a:root) + 1 :]')
  endif
  return filter(map(l:files, 'a:root . "/" . v:val'), 'project_detect#is_test(v:val)')
endfunction

function! s:find_id() abort
  for l:nr in range(1, getqflist({'nr': '$'}).nr)
    let l:info = getqflist({'nr': l:nr, 'title': 1, 'id': 0, 'context': 0})
    if l:info.title ==# s:title && type(l:info.context) == v:t_dict
          \ && get(l:info.context, 'pytest', '') ==# 'tests'
      return l:info.id
    endif
  endfor
  return 0
endfunction

" In a window showing a test list
function! pytest#list#in_list() abort
  if &buftype !=# 'quickfix'
    return 0
  endif
  let l:context = getwininfo(win_getid())[0].loclist
        \ ? getloclist(0, {'context': 0}).context : getqflist({'context': 0}).context
  return type(l:context) == v:t_dict && has_key(l:context, 'pytest')
endfunction

" The node id of the scope around the entry under the cursor, as the same
" key gives it in the entry's file: [nodeid, error]. The entry's test is
" found again where it is now, as a checkout or an edit may have moved it.
function! pytest#list#nodeid(scope) abort
  let l:items = getwininfo(win_getid())[0].loclist
        \ ? getloclist(0, {'items': 1}).items : getqflist({'items': 1}).items
  let l:item = get(l:items, line('.') - 1, {})
  if empty(l:item) || !l:item.bufnr
    return ['', 'no entry here']
  endif
  let l:file = bufname(l:item.bufnr)
  let l:path = pytest#scan#path(l:file)
  let l:lines = pytest#scan#lines(l:file)
  let l:test = get(l:item, 'user_data', {})
  let l:now = filter(pytest#scan#tests(l:path, l:lines),
        \ 'v:val.user_data.nodeid ==# get(l:test, "nodeid", "")')
  if empty(l:now)
    return ['', get(l:test, 'nodeid', l:path) . ' is gone: :PytestTests (or :PytestOutline) again']
  endif
  let l:nodeid = pytest#scan#nodeid(a:scope, l:path, l:lines, l:now[0].lnum)
  return [l:nodeid, empty(l:nodeid) ? 'Could not determine test path for scope: ' . a:scope : '']
endfunction
