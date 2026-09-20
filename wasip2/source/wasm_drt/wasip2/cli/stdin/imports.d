/++

+/
module wasm_drt.wasip2.cli.stdin.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.cli.stdin.common;

static import wasm_drt.wasip2.io.streams.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias InputStream = wasm_drt.wasip2.io.streams.imports.InputStream;

/++

+/
InputStream getStdin() @trusted nothrow {
  auto _ret = __import_getStdin();
  auto _handle0 = InputStream(_ret);
  return _handle0;
}
/// ditto
@wasmImport!("wasi:cli/stdin@0.2.12", "get-stdin")
pragma(mangle, "__wit_import_wasi:cli__stdin@0.2.12__get_stdin")
private extern(C) uint __import_getStdin() nothrow;
