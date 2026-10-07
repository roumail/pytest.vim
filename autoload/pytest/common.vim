
function! pytest#common#NameOfCurrentClass()
  let save_cursor = getpos(".")
  normal! $<cr>
  let find_object = pytest#common#FindPythonObject('class')
  if (find_object)
    let line = getline('.')
    call setpos('.', save_cursor)
    let match_result = matchlist(line, ' *class \+\(\w\+\)')
    return match_result[1]
  endif
endfunction

function! pytest#common#NameOfCurrentFunction()
  normal! $<cr>
  let find_object = pytest#common#FindPythonObject('function')
  if (find_object)
    let line = getline('.')
    let match_result = matchlist(line, ' *def \+\(test\w\+\)')
    echom("match_result: " . string(match_result))
    return match_result[1]
  endif
endfunction

function! pytest#common#NameOfCurrentMethod()
  normal! $<cr>
  let find_object = pytest#common#FindPythonObject('method')
  if (find_object)
    let line = getline('.')
    let match_result = matchlist(line, ' *def \+\(\w\+\)')
    return match_result[1]
  endif
endfunction

" Always goes back to the first instance
" and returns that if found
function! pytest#common#FindPythonObject(obj)
  let orig_line   = line('.')
  let orig_col    = col('.')
  let orig_indent = indent(orig_line)


  if (a:obj == "class")
    let objregexp  = '\v^\s*(.*class)\s+(\w+)\s*'
    let max_indent_allowed = 0
  elseif (a:obj == "method")
    let objregexp = '\v^\s*(.*def)\s+(\w+)\s*\(\_s*(self[^)]*)'
    let max_indent_allowed = 4
  else
    let objregexp = '\v^\s*(.*def)\s+(test\w+)\s*\(\_s*(.*self)@!'
    let max_indent_allowed = orig_indent
  endif

  let flag = "Wb"

  while search(objregexp, flag) > 0
    "
    " Very naive, but if the indent is less than or equal to four
    " keep on going because we assume you are nesting.
    " Do not count lines that are comments though.
    "
    if (indent(line('.')) <= 4) && !(getline(line('.')) =~ '\v^\s*#(.*)')
      if (indent(line('.')) <= max_indent_allowed)
        return 1
      endif
    endif
  endwhile

endfunction

" Generate pytest path for current scope
function! pytest#common#GetTestPath(scope) abort
  let relpath = expand('%')

  if a:scope == 'method'
    let method = pytest#common#NameOfCurrentMethod()
    let class = pytest#common#NameOfCurrentClass()
    if empty(method) || empty(class)
      return ''
    endif
    return relpath . '::' . class . '::' . method

  elseif a:scope == 'class'
    let class = pytest#common#NameOfCurrentClass()
    if empty(class)
      return ''
    endif
    return relpath . '::' . class

  elseif a:scope == 'function'
    let func = pytest#common#NameOfCurrentFunction()
    if empty(func)
      return ''
    endif
    return relpath . '::' . func

  else  " file
    return relpath
  endif
endfunction

function! pytest#common#YankTestPath(type) abort
  let path = pytest#common#GetTestPath(a:type)

  if empty(path)
    echo "Could not determine test path for type: " . a:type
    return
  endif

  " Copy to system clipboard and unnamed register
  let @+ = path
  let @" = path

  echo "Copied: " . path
endfunction
