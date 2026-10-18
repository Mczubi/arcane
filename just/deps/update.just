set working-directory := '../..'

modules := './backend ./cli ./types'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list deps::update

all: frontend go

frontend:
    vp update

# Direct Go dependencies in every module, then sync the workspace (requires jq)
[arg('patch', long, value='true')]
[script('bash')]
go patch='false':
    set -euo pipefail
    version="{{ if patch == 'true' { 'patch' } else { 'upgrade' } }}"
    command -v jq >/dev/null || { echo 'jq is required.' >&2; exit 1; }
    for module in {{ modules }}; do
        (
            cd "$module"
            export GOWORK=off
            echo "Updating direct dependencies in $module..."
            direct=$(go list -mod=mod -m -json all | jq -r '
                select(.Main != true and .Indirect != true)
                | select(.Replace == null or .Replace.Version != null)
                | .Path')
            dependencies=()
            while IFS= read -r dependency; do
                if [ -n "$dependency" ]; then
                    dependencies+=("$dependency@$version")
                fi
            done <<<"$direct"
            if [ "${#dependencies[@]}" -gt 0 ]; then
                go get "${dependencies[@]}"
            fi
            go mod tidy
        )
        go work sync
    done
