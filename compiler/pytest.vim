if exists("current_compiler")
  finish
endif
let current_compiler = "pytest"

let s:command = exists('g:loaded_project_detect') ? project_detect#runner('python').run : 'pytest'
execute 'CompilerSet makeprg=' . escape(s:command . ' $*', ' \|"')
