/++

+/
module wasm_drt.wasip2.cli.stdout.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.cli.stdout.common;

static import wasm_drt.wasip2.io.streams.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias OutputStream = wasm_drt.wasip2.io.streams.imports.OutputStream;

/++

+/
OutputStream getStdout() @trusted nothrow {
  auto _ret = __import_getStdout();
  auto _handle0 = OutputStream(_ret);
  return _handle0;
}
/// ditto
@wasmImport!("wasi:cli/stdout@0.2.12", "get-stdout")
pragma(mangle, "__wit_import_wasi:cli__stdout@0.2.12__get_stdout")
private extern(C) uint __import_getStdout() nothrow;
