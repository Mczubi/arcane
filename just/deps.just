set working-directory := '..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list deps

# Install dependencies: frontend, tests, node, backend, cli, types, go, all
mod install 'deps/install.just'

# Update dependencies: frontend, go [--patch], all
mod update 'deps/update.just'
