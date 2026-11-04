" Headless tests, from the repository's root:
"   vim -Nu NONE -i NONE -Es -S test/run.vim
" Prints one line per test and exits non-zero when one fails; TEST=<pattern>
" in the environment runs the tests whose names match. project-detect comes
" from $PROJECT_DETECT, else vim-plug's copy; vim-dispatch's :Dispatch and
" :Start are stubbed.
set nocompatible hidden
let s:root = expand('<sfile>:p:h:h')
let s:project_detect = empty($PROJECT_DETECT) ? expand('~/.vim/plugged/project-detect') : $PROJECT_DETECT

" A Python project with tests, the current directory before project-detect
" looks
let s:tmp = resolve(tempname())
call mkdir(s:tmp . '/tests', 'p')
call mkdir(s:tmp . '/src/pkg', 'p')
call writefile(['[project]', 'name = "pkg"'], s:tmp . '/pyproject.toml')
call writefile(['def test_not_a_test_file():', '    pass'], s:tmp . '/src/pkg/code.py')
let s:sample = [
      \ 'import pytest',
      \ '',
      \ 'def helper():',
      \ '    return 1',
      \ '',
      \ 'def test_one():',
      \ '    assert helper()',
      \ '',
      \ 'class TestThing:',
      \ '    def setup_method(self):',
      \ '        pass',
      \ '',
      \ '    @pytest.mark.parametrize("x", [1, 2])',
      \ '    def test_a(self, x):',
      \ '        def inner():',
      \ '            pass',
      \ '        assert x',
      \ '',
      \ '    async def test_b(self):',
      \ '        pass',
      \ '',
      \ 'class Helper:',
      \ '    def test_ignored(self):',
      \ '        pass',
      \ '',
      \ 'def test_two(',
      \ '    tmp_path,',
      \ '):',
      \ '    pass',
      \ ]
call writefile(s:sample, s:tmp . '/tests/test_sample.py')
call writefile(['def test_other():', '    pass'], s:tmp . '/tests/test_other.py')
execute 'cd' fnameescape(s:tmp)
" A repository, as projects are: its files are listed with git ls-files
call system('git init -q')

execute 'set runtimepath^=' . fnameescape(s:project_detect)
execute 'set runtimepath^=' . fnameescape(s:root)
" Only these plugins: Vim's own ones aren't all quiet in silent Ex mode
execute 'source' fnameescape(s:project_detect . '/plugin/project_detect.vim')
execute 'source' fnameescape(s:root . '/plugin/pytest.vim')
filetype plugin on
let g:maplocalleader = '_'

let s:ran = []
command! -bang -nargs=* Dispatch call add(s:ran, 'Dispatch<bang> ' . <q-args>)
command! -bang -nargs=* Start call add(s:ran, 'Start<bang> ' . <q-args>)

function! s:reset() abort
  let s:ran = []
  call setqflist([], 'f')
  silent! only!
  silent! %bwipeout!
endfunction

function! s:at(scope, lnum) abort
  return pytest#scan#nodeid(a:scope, 'tests/test_sample.py', s:sample, a:lnum)
endfunction

" Scopes

function! s:test_function() abort
  call assert_equal('tests/test_sample.py::test_one', s:at('function', 6))
  call assert_equal('tests/test_sample.py::test_one', s:at('function', 7))
  " A helper isn't a test; a test function's arguments may span lines
  call assert_equal('', s:at('function', 4))
  call assert_equal('tests/test_sample.py::test_two', s:at('function', 28))
  " In a class
  call assert_equal('', s:at('function', 14))
endfunction

function! s:test_class() abort
  call assert_equal('tests/test_sample.py::TestThing', s:at('class', 9))
  call assert_equal('tests/test_sample.py::TestThing', s:at('class', 17))
  " Not in the class above a function after it
  call assert_equal('', s:at('class', 29))
  call assert_equal('', s:at('class', 1))
endfunction

function! s:test_method() abort
  call assert_equal('tests/test_sample.py::TestThing::test_a', s:at('method', 14))
  " Nested functions are part of their method
  call assert_equal('tests/test_sample.py::TestThing::test_a', s:at('method', 16))
  call assert_equal('tests/test_sample.py::TestThing::test_b', s:at('method', 19))
  call assert_equal('tests/test_sample.py::TestThing::setup_method', s:at('method', 11))
  " On the class line, before any method
  call assert_equal('', s:at('method', 9))
  call assert_equal('', s:at('method', 6))
endfunction

function! s:test_file() abort
  call assert_equal('tests/test_sample.py', s:at('file', 1))
endfunction

function! s:test_tests() abort
  call assert_equal([
        \ [6, 'test_one', 'tests/test_sample.py::test_one', 'function'],
        \ [14, 'TestThing::test_a', 'tests/test_sample.py::TestThing::test_a', 'method'],
        \ [19, 'TestThing::test_b', 'tests/test_sample.py::TestThing::test_b', 'method'],
        \ [26, 'test_two', 'tests/test_sample.py::test_two', 'function'],
        \ ], map(pytest#scan#tests('tests/test_sample.py', s:sample),
        \ '[v:val.lnum, v:val.text, v:val.user_data.nodeid, v:val.user_data.kind]'))
endfunction

" Keys in a test file

function! s:test_file_keys() abort
  edit tests/test_sample.py
  call cursor(14, 1)
  normal _ym
  call assert_equal('tests/test_sample.py::TestThing::test_a', @")
  normal _rc
  normal _tf
  call cursor(6, 1)
  normal _df
  call assert_equal(['Dispatch -compiler=pytest -- tests/test_sample.py::TestThing',
        \ 'Start! -strategy=terminal pytest tests/test_sample.py::test_one --pdb'], s:ran)
  " The commands are the same
  call cursor(14, 1)
  RunPytestScope! method
  call assert_equal('Dispatch! -compiler=pytest -- tests/test_sample.py::TestThing::test_a', s:ran[-1])
  RunPytestScopeTrace method
  call assert_equal('Start! -strategy=terminal pytest tests/test_sample.py::TestThing::test_a --trace', s:ran[-1])
  YankTestClass
  call assert_equal('tests/test_sample.py::TestThing', @")
endfunction

" Lists

function! s:test_tests_list() abort
  PytestTests
  call assert_equal('quickfix', &buftype)
  call assert_equal('Tests', getqflist({'title': 1}).title)
  " Only test files: not src/
  call assert_equal(['tests/test_other.py::test_other',
        \ 'tests/test_sample.py::TestThing::test_a', 'tests/test_sample.py::TestThing::test_b',
        \ 'tests/test_sample.py::test_one', 'tests/test_sample.py::test_two'],
        \ sort(map(getqflist(), 'v:val.user_data.nodeid'), {a, b -> a ==# b ? 0 : a ># b ? 1 : -1}))
  " Run again: the same list, made current, not a new one
  call setqflist([], ' ', {'title': 'grep'})
  PytestTests
  call assert_equal(2, getqflist({'nr': '$'}).nr)
  call assert_equal('Tests', getqflist({'title': 1}).title)
endfunction

function! s:test_list_keys() abort
  PytestTests
  let l:i = index(map(getqflist(), 'v:val.user_data.nodeid'), 'tests/test_sample.py::TestThing::test_a')
  call cursor(l:i + 1, 1)
  normal _ym
  call assert_equal('tests/test_sample.py::TestThing::test_a', @")
  normal _yc
  call assert_equal('tests/test_sample.py::TestThing', @")
  normal _yt
  call assert_equal('tests/test_sample.py', @")
  " Not a function: as in the file
  let @" = ''
  normal _yf
  call assert_equal('', @")
  normal _rm
  call assert_equal(['Dispatch -compiler=pytest -- tests/test_sample.py::TestThing::test_a'], s:ran)
endfunction

function! s:test_list_entry_moved_or_gone() abort
  edit tests/test_other.py
  PytestTests
  let l:i = index(map(getqflist(), 'v:val.user_data.nodeid'), 'tests/test_other.py::test_other')
  " As a checkout leaves it: lines added above the test
  call win_gotoid(bufwinid('tests/test_other.py'))
  call append(0, ['def test_added():', '    pass', '', ''])
  copen
  call cursor(l:i + 1, 1)
  normal _yf
  call assert_equal('tests/test_other.py::test_other', @")
  " And gone
  call win_gotoid(bufwinid('tests/test_other.py'))
  silent %delete _
  copen
  call cursor(l:i + 1, 1)
  let @" = ''
  normal _yf
  call assert_equal('', @")
  call win_gotoid(bufwinid('tests/test_other.py'))
  edit!
endfunction

function! s:test_keys_only_in_test_lists() abort
  call setqflist([], ' ', {'title': 'grep', 'items': [{'filename': 'tests/test_sample.py', 'lnum': 14, 'text': 'x'}]})
  copen
  let @" = 'kept'
  silent! normal _ym
  call assert_equal('kept', @")
  call assert_equal([], s:ran)
endfunction

function! s:test_outline() abort
  edit tests/test_sample.py
  let l:win = win_getid()
  PytestOutline
  call assert_equal(1, getwininfo(win_getid())[0].loclist)
  call assert_equal('Tests: tests/test_sample.py', getloclist(0, {'title': 1}).title)
  call assert_equal(['test_one', 'TestThing::test_a', 'TestThing::test_b', 'test_two'],
        \ map(getloclist(0), 'v:val.text'))
  call cursor(2, 1)
  normal _yc
  call assert_equal('tests/test_sample.py::TestThing', @")
  " Again: replaced, not stacked
  call win_gotoid(l:win)
  PytestOutline
  call assert_equal(1, getloclist(0, {'nr': '$'}).nr)
endfunction

function! s:test_unsaved_edits_count() abort
  edit tests/test_other.py
  call append(line('$'), ['', 'def test_new():', '    pass'])
  wincmd p
  PytestTests
  call assert_true(index(map(getqflist(), 'v:val.user_data.nodeid'), 'tests/test_other.py::test_new') >= 0)
  call win_gotoid(bufwinid('tests/test_other.py'))
  edit!
endfunction

let s:failed = 0
let s:prefix = expand('<SID>') . 'test_'
let s:names = []
for s:line in split(execute('function'), "\n")
  if stridx(s:line, 'function ' . s:prefix) == 0
    call add(s:names, matchstr(s:line, 'function ' . s:prefix . '\zs\w\+'))
  endif
endfor
for s:name in s:names
  if !empty($TEST) && s:name !~# $TEST
    continue
  endif
  call s:reset()
  let v:errors = []
  try
    call call(s:prefix . s:name, [])
  catch
    call add(v:errors, v:exception . ' @ ' . v:throwpoint)
  endtry
  if empty(v:errors)
    call writefile(['ok   ' . s:name], '/dev/stdout', 'a')
  else
    let s:failed += 1
    call writefile(['FAIL ' . s:name] + map(copy(v:errors), '"     " . v:val'), '/dev/stdout', 'a')
  endif
endfor
call writefile([s:failed ? s:failed . ' failed' : 'all passed'], '/dev/stdout', 'a')
call delete(s:tmp, 'rf')
execute s:failed ? 'cquit 1' : 'cquit 0'
