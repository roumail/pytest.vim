" Finds tests in a Python file's lines, without running pytest. The keys in
" a test file and in the test lists both go through here, so they agree on
" what a test is.

" The classes and functions defined in lines: [{lnum, indent, kind, name}],
" kind 'class' or 'def'
function! pytest#scan#defs(lines) abort
  let l:defs = []
  let l:lnum = 0
  for l:line in a:lines
    let l:lnum += 1
    let l:m = matchlist(l:line, '\v^(\s*)%(async\s+)?(class|def)\s+(\w+)')
    if !empty(l:m)
      call add(l:defs, {'lnum': l:lnum, 'indent': strdisplaywidth(l:m[1]),
            \ 'kind': l:m[2], 'name': l:m[3]})
    endif
  endfor
  return l:defs
endfunction

" The node id of the scope ('method', 'class', 'function' or 'file') around
" line lnum of lines, the file at path: path::Class::method, path::Class,
" path::test_function or path. '' when there is no such scope there.
"   function  the module-level test function lnum is in
"   class     the module-level class lnum is in
"   method    the method of that class lnum is in (nested functions are
"             part of their method)
function! pytest#scan#nodeid(scope, path, lines, lnum) abort
  if a:scope ==# 'file'
    return a:path
  endif
  let l:defs = pytest#scan#defs(a:lines)
  let l:top = get(filter(copy(l:defs), 'v:val.indent == 0 && v:val.lnum <= a:lnum'), -1, {})
  if empty(l:top)
    return ''
  endif
  if a:scope ==# 'function'
    return l:top.kind ==# 'def' && l:top.name =~# '^test'
          \ ? a:path . '::' . l:top.name : ''
  endif
  if l:top.kind !=# 'class'
    return ''
  endif
  if a:scope ==# 'class'
    return a:path . '::' . l:top.name
  endif
  let l:methods = s:methods(l:defs, l:top)
  let l:method = get(filter(l:methods, 'v:val.lnum <= a:lnum'), -1, {})
  return empty(l:method) ? '' : a:path . '::' . l:top.name . '::' . l:method.name
endfunction

" The methods of the module-level class cls: the least indented defs in it
function! s:methods(defs, cls) abort
  let l:body = []
  for l:def in a:defs
    if l:def.lnum <= a:cls.lnum
      continue
    elseif l:def.indent == 0
      break
    endif
    call add(l:body, l:def)
  endfor
  let l:defs = filter(l:body, 'v:val.kind ==# "def"')
  if empty(l:defs)
    return []
  endif
  let l:indent = min(map(copy(l:defs), 'v:val.indent'))
  return filter(l:defs, 'v:val.indent == l:indent')
endfunction

" The tests pytest collects by default in lines, the file at path, as
" quickfix items: module-level test_* functions, and the test_* methods of
" module-level Test* classes. Parametrised tests are one item.
function! pytest#scan#tests(path, lines) abort
  let l:items = []
  let l:defs = pytest#scan#defs(a:lines)
  for l:top in filter(copy(l:defs), 'v:val.indent == 0')
    if l:top.kind ==# 'def' && l:top.name =~# '^test'
      call add(l:items, s:item(a:path, l:top.lnum, [l:top.name], 'function'))
    elseif l:top.kind ==# 'class' && l:top.name =~# '^Test'
      for l:method in filter(s:methods(l:defs, l:top), 'v:val.name =~# "^test"')
        call add(l:items, s:item(a:path, l:method.lnum, [l:top.name, l:method.name], 'method'))
      endfor
    endif
  endfor
  return l:items
endfunction

function! s:item(path, lnum, names, kind) abort
  let l:name = join(a:names, '::')
  return {'filename': a:path, 'lnum': a:lnum, 'text': l:name,
        \ 'user_data': {'nodeid': a:path . '::' . l:name, 'kind': a:kind}}
endfunction

" A file as pytest is given it: relative to the current directory, where
" tests run
function! pytest#scan#path(file) abort
  return fnamemodify(fnamemodify(a:file, ':p'), ':.')
endfunction

" A file's lines: its buffer's when loaded, so unsaved edits count
function! pytest#scan#lines(file) abort
  let l:file = fnamemodify(a:file, ':p')
  for l:buf in getbufinfo({'bufloaded': 1})
    if !empty(l:buf.name) && fnamemodify(l:buf.name, ':p') ==# l:file
      return getbufline(l:buf.bufnr, 1, '$')
    endif
  endfor
  return filereadable(l:file) ? readfile(l:file) : []
endfunction
