if exists('b:loaded_python_pytest_ftplugin')
  finish
endif

" Required plugin. ftplugins run after every plugin has loaded, so its
" g:loaded_* guard tells whether it is installed. Warn once per session.
if !exists('g:loaded_dispatch')
  if !get(g:, 'pytest_warned_missing', 0)
    let g:pytest_warned_missing = 1
    echohl WarningMsg
    echomsg 'pytest.vim: requires tpope/vim-dispatch; Python buffers get no pytest commands'
    echohl None
  endif
  finish
endif
let b:loaded_python_pytest_ftplugin = 1

" vim dispatch
compiler pytest
" https://github.com/tpope/vim-dispatch/issues/315
let b:dispatch = '-compiler=pytest'

" Copy test paths to clipboard/register without running
command! -buffer YankTestMethod call pytest#common#YankTestPath('method')
command! -buffer YankTestClass call pytest#common#YankTestPath('class')
command! -buffer YankTestFunction call pytest#common#YankTestPath('function')
command! -buffer YankTestFile call pytest#common#YankTestPath('file')

" Direct Pytest dispatch with custom args, to run all tests for example
command! -buffer -bang -nargs=* RunPytest call pytest#dispatch#Dispatch("<bang>", <q-args>)
" TracePytest - automatically adds --trace for interactive debugging with custom args
command! -buffer -bang -nargs=* TracePytest call pytest#dispatch#StartPytest(<q-args> . ' --trace')
" Scope-based shortcuts
command! -buffer -bang -nargs=1 RunPytestScope call pytest#dispatch#WithScope(<q-args>, "<bang>")
command! -buffer -nargs=1 -bang RunPytestScopeTrace call pytest#dispatch#WithScopeAndTrace(<q-args>, "<bang>")

" Keys from g:pytest_mappings, in test files only
call pytest#mappings#apply()
