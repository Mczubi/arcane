set working-directory := '..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list bench

# Edge tunnel transports with allocation counts
edge count="3" benchtime="2s":
    cd backend && go test -run '^$' -bench '^BenchmarkEdgeTunnelProxyRequest$' -benchmem -count={{ count }} -benchtime={{ benchtime }} ./pkg/libarcane/edge

# Edge tunnel transports with a memory profile
memory profile="edge_tunnel.mem.out" benchtime="5s":
    cd backend && go test -run '^$' -bench '^BenchmarkEdgeTunnelProxyRequest$' -benchmem -benchtime={{ benchtime }} -memprofile={{ profile }} ./pkg/libarcane/edge
