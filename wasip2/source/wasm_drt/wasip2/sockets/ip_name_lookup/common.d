/++

+/
module wasm_drt.wasip2.sockets.ip_name_lookup.common;


import wasm_drt.wasip2.wit;

static import wasm_drt.wasip2.io.poll.common;
static import wasm_drt.wasip2.sockets.network.common;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias ErrorCode = wasm_drt.wasip2.sockets.network.common.ErrorCode;

/++

+/
alias IpAddress = wasm_drt.wasip2.sockets.network.common.IpAddress;
