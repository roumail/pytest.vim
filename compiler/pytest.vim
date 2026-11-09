let current_compiler = "pytest"

execute 'CompilerSet makeprg=' . escape(pytest#command() . ' $*', ' \|"')
