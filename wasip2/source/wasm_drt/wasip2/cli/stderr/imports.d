/++

+/
module wasm_drt.wasip2.cli.stderr.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.cli.stderr.common;

static import wasm_drt.wasip2.io.streams.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias OutputStream = wasm_drt.wasip2.io.streams.imports.OutputStream;

/++

+/
OutputStream getStderr() @trusted nothrow {
  auto _ret = __import_getStderr();
  auto _handle0 = OutputStream(_ret);
  return _handle0;
}
/// ditto
@wasmImport!("wasi:cli/stderr@0.2.12", "get-stderr")
pragma(mangle, "__wit_import_wasi:cli__stderr@0.2.12__get_stderr")
private extern(C) uint __import_getStderr() nothrow;
