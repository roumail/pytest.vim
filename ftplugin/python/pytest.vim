if exists('b:loaded_python_pytest_ftplugin')
  finish
endif
let b:loaded_python_pytest_ftplugin = 1

compiler pytest
" https://github.com/tpope/vim-dispatch/issues/315
let b:dispatch = '-compiler=pytest'

" Direct Pytest dispatch with custom args, to run all tests for example
command! -buffer -bang -nargs=* -complete=file RunPytest call pytest#dispatch#Dispatch("<bang>", <q-args>)
" TracePytest - automatically adds --trace for interactive debugging with custom args
command! -buffer -bang -nargs=* -complete=file TracePytest call pytest#dispatch#StartPytest(<q-args> . ' --trace')

" Keys, in the project's test files only (which project-detect tells, run on
" every Python buffer)
if pytest#has_project_detect()
  call pytest#mappings#apply()
endif
