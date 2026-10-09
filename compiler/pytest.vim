" filepath: ~/.vim/compiler/pytest.vim
if exists("current_compiler")
  finish
endif
let current_compiler = "pytest"

" Tests run with project-detect's Python runner (default: pytest)
let s:command = exists('g:loaded_project_detect') ? project_detect#runner('python').run : 'pytest'
execute 'CompilerSet makeprg=' . escape(s:command . ' $*', ' \|"')
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
