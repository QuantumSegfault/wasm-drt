/++

+/
module wasm_drt.wasip2.random.insecure.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.random.insecure.common;


package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
WitList!(ubyte) getInsecureRandomBytes(ulong len) @trusted @nogc nothrow {
  align(size_t.sizeof) void[(2*size_t.sizeof)] _retArea = void;
  __import_getInsecureRandomBytes(len, _retArea.ptr);
  auto _len0 = *(cast(size_t*)(_retArea.ptr + size_t.sizeof));
  auto _ptr0 = _len0 ? cast(ubyte*)(*(cast(void**)(_retArea.ptr + 0))) : null;
  auto _list1 = WitList!(ubyte)(_ptr0[0.._len0]);
  auto _flush2 = _list1;
  return _flush2;
}
/// ditto
@wasmImport!("wasi:random/insecure@0.2.12", "get-insecure-random-bytes")
pragma(mangle, "__wit_import_wasi:random__insecure@0.2.12__get_insecure_random_bytes")
private extern(C) void __import_getInsecureRandomBytes(ulong, void*) @nogc nothrow;

/++

+/
ulong getInsecureRandomU64() @trusted @nogc nothrow {
  auto _ret = __import_getInsecureRandomU64();
  return _ret;
}
/// ditto
@wasmImport!("wasi:random/insecure@0.2.12", "get-insecure-random-u64")
pragma(mangle, "__wit_import_wasi:random__insecure@0.2.12__get_insecure_random_u64")
private extern(C) ulong __import_getInsecureRandomU64() @nogc nothrow;
