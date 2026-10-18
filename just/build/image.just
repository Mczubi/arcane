set working-directory := '../..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list build::image

[arg('push', long, value='--push')]
manager tag='arcane:latest' push='':
    docker buildx build {{ push }} --platform linux/arm64,linux/amd64,linux/arm/v7 -f 'docker/Dockerfile' --build-arg ENABLED_FEATURES="{{ env('ENABLED_FEATURES', env('BUILD_FEATURES', '')) }}" -t "{{ tag }}" .

[arg('push', long, value='--push')]
agent tag='arcane-agent:latest' push='':
    docker buildx build {{ push }} --platform linux/arm64,linux/amd64,linux/arm/v7 -f 'docker/Dockerfile-agent' --build-arg ENABLED_FEATURES="{{ env('ENABLED_FEATURES', env('BUILD_FEATURES', '')) }}" -t "{{ tag }}" .
