" filepath: ~/.vim/compiler/pytest.vim
if exists("current_compiler")
  finish
endif
let current_compiler = "pytest"

" g:pytest_command runs the tests (default: pytest)
execute 'CompilerSet makeprg=' . escape(get(g:, 'pytest_command', 'pytest') . ' $*', ' \|"')
" Pytest error format
" CompilerSet errorformat=
"     \%E%f:%l:\ %.%#,
"     \%ZFAILED\ %m,
"     \%ZERROR\ %m,
"     \%-G%.%#
" CompilerSet errorformat=
"     \%E%f:%l:\ in\ %m,
"     \%E\ \ \ \ %f:%l:\ in\ %m,
"     \%E%f:%l:\ %m,
"     \%EFAILED\ %f::%m,
"     \%EERROR\ %f::%m,
"     \%C\ \ \ \ %m,
"     \%Z\ \ %m,
"     \%-G%.%#
