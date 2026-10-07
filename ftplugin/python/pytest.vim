" Nothing when plugin/pytest.vim didn't load (vim-dispatch missing)
if !exists('g:loaded_pytest_tools')
  finish
endif

" vim dispatch
compiler pytest
" https://github.com/tpope/vim-dispatch/issues/315
let b:dispatch = '-compiler=pytest'
" Set default dispach strategy for start to be terminal, not tmux
let g:dispatch_no_tmux_start = 1

if exists('b:loaded_python_pytest_ftplugin')
  finish
endif
let b:loaded_python_pytest_ftplugin = 1

augroup pytest_parse
  autocmd!
  " This runs AFTER dispatch completes and populates quickfix
  autocmd QuickFixCmdPost dispatch call pytest#failures#Parse()
augroup END

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
