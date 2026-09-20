/++

+/
module wasm_drt.wasip2.sockets.instance_network.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.sockets.instance_network.common;

static import wasm_drt.wasip2.sockets.network.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Network = wasm_drt.wasip2.sockets.network.imports.Network;

/++

+/
Network instanceNetwork() @trusted nothrow {
  auto _ret = __import_instanceNetwork();
  auto _handle0 = Network(_ret);
  return _handle0;
}
/// ditto
@wasmImport!("wasi:sockets/instance-network@0.2.12", "instance-network")
pragma(mangle, "__wit_import_wasi:sockets__instance_network@0.2.12__instance_network")
private extern(C) uint __import_instanceNetwork() nothrow;
