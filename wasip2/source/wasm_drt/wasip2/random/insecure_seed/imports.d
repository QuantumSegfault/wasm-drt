/++

+/
module wasm_drt.wasip2.random.insecure_seed.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.random.insecure_seed.common;


package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
Tuple!(ulong, ulong) insecureSeed() @trusted @nogc nothrow {
  align(8) void[16] _retArea = void;
  __import_insecureSeed(_retArea.ptr);
  auto _tuple0 = Tuple!(ulong, ulong)(
  *(cast(ulong*)(_retArea.ptr + 0)),
  *(cast(ulong*)(_retArea.ptr + 8)),
  );
  auto _flush1 = _tuple0;
  return _flush1;
}
/// ditto
@wasmImport!("wasi:random/insecure-seed@0.2.12", "insecure-seed")
pragma(mangle, "__wit_import_wasi:random__insecure_seed@0.2.12__insecure_seed")
private extern(C) void __import_insecureSeed(void*) @nogc nothrow;
