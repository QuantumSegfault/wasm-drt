/++

+/
module wasm_drt.wasip2.clocks.wall_clock.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.clocks.wall_clock.common;


package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
Datetime now() @trusted @nogc nothrow {
  align(8) void[16] _retArea = void;
  __import_now(_retArea.ptr);
  Datetime _record0 = {
    seconds: *(cast(ulong*)(_retArea.ptr + 0)),
    nanoseconds: *(cast(uint*)(_retArea.ptr + 8)),
  };
  auto _flush1 = _record0;
  return _flush1;
}
/// ditto
@wasmImport!("wasi:clocks/wall-clock@0.2.12", "now")
pragma(mangle, "__wit_import_wasi:clocks__wall_clock@0.2.12__now")
private extern(C) void __import_now(void*) @nogc nothrow;

/++

+/
Datetime resolution() @trusted @nogc nothrow {
  align(8) void[16] _retArea = void;
  __import_resolution(_retArea.ptr);
  Datetime _record0 = {
    seconds: *(cast(ulong*)(_retArea.ptr + 0)),
    nanoseconds: *(cast(uint*)(_retArea.ptr + 8)),
  };
  auto _flush1 = _record0;
  return _flush1;
}
/// ditto
@wasmImport!("wasi:clocks/wall-clock@0.2.12", "resolution")
pragma(mangle, "__wit_import_wasi:clocks__wall_clock@0.2.12__resolution")
private extern(C) void __import_resolution(void*) @nogc nothrow;
