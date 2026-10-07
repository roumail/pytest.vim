" Reduce pytest output (or coverage test contexts) in the current buffer to
" one line per test, grouped into blank-line separated blocks.
"
"   :ParsePytestFailures    one block per file
"   :ParsePytestFailures!   one block per test class (module-level tests of a
"                           file form their own block)
"
" Blocks with fewer lines are moved towards the top (ties keep alphabetical
" order).
function! pytest#failures#Parse(...) abort
  let l:by_class = a:0 ? a:1 : 0

  " Pytest output: keep only FAILED / ERROR lines, ignoring anything before
  " them (whitespace, timestamps, [gw0] ...). The lookahead requires a *.py
  " path after the marker, so log lines like "ERROR: boom" are not picked up.
  " Skipped for pasted coverage contexts, which have no such lines and would
  " otherwise all be deleted.
  let l:marker = '^.\{-}\<\%(FAILED\|ERROR\)\s\+\ze\S\+\.py'
  if search(l:marker, 'nw')
    execute 'g!/' . l:marker . '/d'
    " Remove everything up to and including the FAILED/ERROR prefix
    execute '%s/' . l:marker . '//e'
    " Remove the trailing error message (pytest separates it with ' - ')
    %s/\s-.*$//e
  endif

  " Remove coverage context phase, e.g. test_foo[a-1]|run -> test_foo[a-1]
  %s/|\(run\|setup\|teardown\)$//e

  " Remove parametrization ids, e.g. test_foo[a-1] -> test_foo
  %s/\[.*\]$//e

  " Sort and remove duplicates
  sort u

  call s:GroupPytestBlocks(l:by_class)
endfunction

" Split the (sorted, unique) buffer lines into blocks keyed by file, or by
" file::Class when by_class is set, sort the blocks by line count (smallest
" first) and write them back separated by an empty line.
function! s:GroupPytestBlocks(by_class) abort
  let l:order = []
  let l:groups = {}
  for l:line in getline(1, '$')
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

  silent %delete _
  call setline(1, l:out)
endfunction
