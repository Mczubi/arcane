set working-directory := '..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list snyk

# Scan all projects, including dev dependencies
scan:
    snyk test --all-projects --dev --policy-path=.snyk
