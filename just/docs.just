set working-directory := '..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list docs

# Docs config schema JSON
[script('bash')]
config output="" source_root=".":
    set -euo pipefail

    cmd=(go run -tags exclude_frontend ./backend/cmd config-schema --source-root "{{ source_root }}")
    if [ -n "{{ output }}" ]; then
        cmd+=(--output "{{ output }}")
    fi

    "${cmd[@]}"
