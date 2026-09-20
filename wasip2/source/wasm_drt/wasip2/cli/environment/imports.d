/++

+/
module wasm_drt.wasip2.cli.environment.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.cli.environment.common;


package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++
Get the POSIX-style environment variables.

Each environment variable is provided as a pair of string variable names
and string value.

Morally, these are a value import, but until value imports are available
in the component model, this import function should return the same
values each time it is called.
+/
WitList!(Tuple!(WitString, WitString)) getEnvironment() @trusted nothrow {
  align(size_t.sizeof) void[(2*size_t.sizeof)] _retArea = void;
  __import_getEnvironment(_retArea.ptr);
  auto _listSrcPtr6 = *(cast(void**)(_retArea.ptr + 0));
  auto _listLen6 = *(cast(size_t*)(_retArea.ptr + size_t.sizeof));
  auto _list6 = _listLen6 ? wasm_drt.wasip2.wit.mallocSlice!(Tuple!(WitString, WitString))(_listLen6) : [];
  assert(!_listLen6 || _list6.ptr);
  foreach (_elem0_idx, ref _elem0; _list6) {
    const auto _base0 = _listSrcPtr6 + _elem0_idx * (4*size_t.sizeof);
    auto _len1 = *(cast(size_t*)(_base0 + size_t.sizeof));
    auto _ptr1 = _len1 ? cast(char*)(*(cast(void**)(_base0 + 0))) : null;
    auto _list2 = WitString(_ptr1[0.._len1]);
    auto _len3 = *(cast(size_t*)(_base0 + (3*size_t.sizeof)));
    auto _ptr3 = _len3 ? cast(char*)(*(cast(void**)(_base0 + (2*size_t.sizeof)))) : null;
    auto _list4 = WitString(_ptr3[0.._len3]);
    auto _tuple5 = Tuple!(WitString, WitString)(
    _list2,
    _list4,
    );
    _elem0 = _tuple5;
  }
  if (_listLen6) wasm_drt.wasip2.wit.free(_listSrcPtr6);
  auto _witList7 = WitList!(Tuple!(WitString, WitString))(_list6);
  auto _flush8 = _witList7;
  return _flush8;
}
/// ditto
@wasmImport!("wasi:cli/environment@0.2.12", "get-environment")
pragma(mangle, "__wit_import_wasi:cli__environment@0.2.12__get_environment")
private extern(C) void __import_getEnvironment(void*) nothrow;

/++
Get the POSIX-style arguments to the program.
+/
WitList!(WitString) getArguments() @trusted nothrow {
  align(size_t.sizeof) void[(2*size_t.sizeof)] _retArea = void;
  __import_getArguments(_retArea.ptr);
  auto _listSrcPtr3 = *(cast(void**)(_retArea.ptr + 0));
  auto _listLen3 = *(cast(size_t*)(_retArea.ptr + size_t.sizeof));
  auto _list3 = _listLen3 ? wasm_drt.wasip2.wit.mallocSlice!(WitString)(_listLen3) : [];
  assert(!_listLen3 || _list3.ptr);
  foreach (_elem0_idx, ref _elem0; _list3) {
    const auto _base0 = _listSrcPtr3 + _elem0_idx * (2*size_t.sizeof);
    auto _len1 = *(cast(size_t*)(_base0 + size_t.sizeof));
    auto _ptr1 = _len1 ? cast(char*)(*(cast(void**)(_base0 + 0))) : null;
    auto _list2 = WitString(_ptr1[0.._len1]);
    _elem0 = _list2;
  }
  if (_listLen3) wasm_drt.wasip2.wit.free(_listSrcPtr3);
  auto _witList4 = WitList!(WitString)(_list3);
  auto _flush5 = _witList4;
  return _flush5;
}
/// ditto
@wasmImport!("wasi:cli/environment@0.2.12", "get-arguments")
pragma(mangle, "__wit_import_wasi:cli__environment@0.2.12__get_arguments")
private extern(C) void __import_getArguments(void*) nothrow;

/++
Return a path that programs should use as their initial current working
directory, interpreting `.` as shorthand for this.
+/
Option!(WitString) initialCwd() @trusted nothrow {
  align(size_t.sizeof) void[(3*size_t.sizeof)] _retArea = void;
  __import_initialCwd(_retArea.ptr);
  Option!(WitString) _option4 = void;
  bool _isSome4 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
  if (_isSome4) {
    auto _len2 = *(cast(size_t*)(_retArea.ptr + (2*size_t.sizeof)));
    auto _ptr2 = _len2 ? cast(char*)(*(cast(void**)(_retArea.ptr + size_t.sizeof))) : null;
    auto _list3 = WitString(_ptr2[0.._len2]);

    _option4 = Option!(WitString).makeSome(_list3);
  } else {
    _option4 = Option!(WitString).makeNone;
  }
  auto _flush5 = _option4;
  return _flush5;
}
/// ditto
@wasmImport!("wasi:cli/environment@0.2.12", "initial-cwd")
pragma(mangle, "__wit_import_wasi:cli__environment@0.2.12__initial_cwd")
private extern(C) void __import_initialCwd(void*) nothrow;
