/++

+/
module wasm_drt.wasip2.random.random.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.random.random.common;


package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
WitList!(ubyte) getRandomBytes(ulong len) @trusted nothrow {
  align(size_t.sizeof) void[(2*size_t.sizeof)] _retArea = void;
  __import_getRandomBytes(len, _retArea.ptr);
  auto _len0 = *(cast(size_t*)(_retArea.ptr + size_t.sizeof));
  auto _ptr0 = _len0 ? cast(ubyte*)(*(cast(void**)(_retArea.ptr + 0))) : null;
  auto _list1 = WitList!(ubyte)(_ptr0[0.._len0]);
  auto _flush2 = _list1;
  return _flush2;
}
/// ditto
@wasmImport!("wasi:random/random@0.2.12", "get-random-bytes")
pragma(mangle, "__wit_import_wasi:random__random@0.2.12__get_random_bytes")
private extern(C) void __import_getRandomBytes(ulong, void*) nothrow;

/++

+/
ulong getRandomU64() @trusted nothrow {
  auto _ret = __import_getRandomU64();
  return _ret;
}
/// ditto
@wasmImport!("wasi:random/random@0.2.12", "get-random-u64")
pragma(mangle, "__wit_import_wasi:random__random@0.2.12__get_random_u64")
private extern(C) ulong __import_getRandomU64() nothrow;
