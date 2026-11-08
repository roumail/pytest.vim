let current_compiler = "pytest"

let s:command = pytest#has_project_detect() ? project_detect#runner('python').run : 'pytest'
execute 'CompilerSet makeprg=' . escape(s:command . ' $*', ' \|"')
