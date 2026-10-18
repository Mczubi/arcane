import 'settings.just'

set working-directory := '..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list generate

# Edge tunnel protobuf/gRPC code
proto:
    {{ just_executable() }} lint proto
    cd {{ edge_proto_dir }} && go run github.com/bufbuild/buf/cmd/buf@latest generate
