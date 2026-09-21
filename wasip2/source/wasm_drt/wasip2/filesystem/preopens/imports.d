/++

+/
module wasm_drt.wasip2.filesystem.preopens.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.filesystem.preopens.common;

static import wasm_drt.wasip2.filesystem.types.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Descriptor = wasm_drt.wasip2.filesystem.types.imports.Descriptor;

/++

+/
WitList!(Tuple!(Descriptor, WitString)) getDirectories() @trusted @nogc nothrow {
  align(size_t.sizeof) void[(2*size_t.sizeof)] _retArea = void;
  __import_getDirectories(_retArea.ptr);
  auto _listSrcPtr5 = *(cast(void**)(_retArea.ptr + 0));
  auto _listLen5 = *(cast(size_t*)(_retArea.ptr + size_t.sizeof));
  auto _list5 = _listLen5 ? wasm_drt.wasip2.wit.mallocSlice!(Tuple!(Descriptor, WitString))(_listLen5) : [];
  assert(!_listLen5 || _list5.ptr);
  foreach (_elem0_idx, ref _elem0; _list5) {
    const auto _base0 = _listSrcPtr5 + _elem0_idx * (3*size_t.sizeof);
    auto _handle1 = Descriptor(*(cast(uint*)(_base0 + 0)));
    auto _len2 = *(cast(size_t*)(_base0 + (2*size_t.sizeof)));
    auto _ptr2 = _len2 ? cast(char*)(*(cast(void**)(_base0 + size_t.sizeof))) : null;
    auto _list3 = WitString(_ptr2[0.._len2]);
    auto _tuple4 = Tuple!(Descriptor, WitString)(
    _handle1,
    _list3,
    );
    _elem0 = _tuple4;
  }
  if (_listLen5) wasm_drt.wasip2.wit.free(_listSrcPtr5);
  auto _witList6 = WitList!(Tuple!(Descriptor, WitString))(_list5);
  auto _flush7 = _witList6;
  return _flush7;
}
/// ditto
@wasmImport!("wasi:filesystem/preopens@0.2.12", "get-directories")
pragma(mangle, "__wit_import_wasi:filesystem__preopens@0.2.12__get_directories")
private extern(C) void __import_getDirectories(void*) @nogc nothrow;
