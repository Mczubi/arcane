set working-directory := '../..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list build::single

all: frontend backend

frontend:
    vp -C frontend run build

backend:
    cd backend && go build ./...
