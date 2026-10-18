set working-directory := '..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list fix

# Apply go fix to every Go module
all: backend cli types

backend:
    cd backend && go fix ./...

cli:
    cd cli && go fix ./...

types:
    cd types && go fix ./...
