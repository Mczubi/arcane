set working-directory := '..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list build

# Application code: frontend, backend, all
mod single 'build/single.just'

# Container images: manager, agent [tag] [--push]
mod image 'build/image.just'
