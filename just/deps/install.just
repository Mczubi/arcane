set working-directory := '../..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list deps::install

all: node go

# pnpm workspace dependencies
frontend:
    vp install

# Playwright test dependencies and browser
tests:
    vp -C tests install
    vp -C tests exec playwright install --with-deps chromium

node: frontend tests

go: backend cli types

backend:
    cd backend && go mod download && go mod tidy && go mod verify
    go work sync

cli:
    cd cli && go mod download && go mod tidy && go mod verify
    go work sync

types:
    cd types && go mod download && go mod tidy && go mod verify
    go work sync
