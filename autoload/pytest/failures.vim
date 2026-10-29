" Reduce pytest output (or coverage test contexts) in lines line1 to line2 of
" the current buffer to one line per test, grouped into blank-line separated
" blocks.
"
"   :[range]ParsePytestFailures    one block per file
"   :[range]ParsePytestFailures!   one block per test class (module-level
"                                  tests of a file form their own block)
"
" The range defaults to the whole buffer. Blocks with fewer lines are moved
" towards the top (ties keep alphabetical order).
function! pytest#failures#Parse(by_class, line1, line2) abort
  let l:lines = getline(a:line1, a:line2)

  " Pytest output: keep only FAILED / ERROR lines, ignoring anything before
  " them (whitespace, timestamps, [gw0] ...). The lookahead requires a *.py
  " path after the marker, so log lines like "ERROR: boom" are not picked up.
  " Skipped for pasted coverage contexts, which have no such lines and would
  " otherwise all be deleted.
  let l:marker = '^.\{-}\<\%(FAILED\|ERROR\)\s\+\ze\S\+\.py'
  if match(l:lines, l:marker) >= 0
    call filter(l:lines, {_, v -> v =~# l:marker})
    " Remove the marker and the trailing error message (pytest separates it
    " with ' - ')
    call map(l:lines, {_, v -> substitute(substitute(v, l:marker, '', ''), '\s-.*$', '', '')})
  endif

  " Remove coverage context phase, e.g. test_foo[a-1]|run -> test_foo[a-1],
  " then parametrization ids, e.g. test_foo[a-1] -> test_foo
  call map(l:lines, {_, v -> substitute(substitute(v,
        \ '|\(run\|setup\|teardown\)$', '', ''), '\[.*\]$', '', '')})

  call s:Replace(a:line1, a:line2, s:GroupPytestBlocks(uniq(sort(l:lines)), a:by_class))
endfunction

" Replace lines line1 to line2 with lines
function! s:Replace(line1, line2, lines) abort
  let l:count = a:line2 - a:line1 + 1
  call setline(a:line1, a:lines[: l:count - 1])
  if len(a:lines) < l:count
    silent execute (a:line1 + len(a:lines)) . ',' . a:line2 . 'delete _'
  elseif len(a:lines) > l:count
    call append(a:line2, a:lines[l:count :])
  endif
endfunction

" Split the (sorted, unique) lines into blocks keyed by file, or by
" file::Class when by_class is set, sort the blocks by line count (smallest
" first) and return them separated by an empty line.
function! s:GroupPytestBlocks(lines, by_class) abort
  let l:order = []
  let l:groups = {}
  for l:line in a:lines
    if empty(l:line)
      continue
    endif
    let l:parts = split(l:line, '::')
    if empty(l:parts)
      let l:key = l:line
    elseif a:by_class && len(l:parts) > 1
      " everything but the test name: file or file::Class[::Nested]
      let l:key = join(l:parts[0 : -2], '::')
    else
      let l:key = l:parts[0]
    endif
    if !has_key(l:groups, l:key)
      let l:groups[l:key] = []
      call add(l:order, l:key)
    endif
    call add(l:groups[l:key], l:line)
  endfor

  " sort() is stable, so equally sized blocks keep their alphabetical order
  let l:blocks = map(copy(l:order), {_, k -> l:groups[k]})
  call sort(l:blocks, {a, b -> len(a) - len(b)})

  let l:out = []
  for l:block in l:blocks
    if !empty(l:out)
      call add(l:out, '')
    endif
    call extend(l:out, l:block)
  endfor
  return l:out
endfunction
