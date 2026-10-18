set working-directory := '..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list repo

# Remove build artifacts, node_modules, and Go build/test caches
[script('bash')]
clean:
    set -euo pipefail
    rm -rf frontend/.svelte-kit frontend/build backend/.bin
    find . -type d -name node_modules -prune -exec rm -rf {} \;
    go clean -cache -testcache

    gotmp="$(go env GOTMPDIR)"
    if [ -n "$gotmp" ]; then
        find "$gotmp" -mindepth 1 -delete
    fi
