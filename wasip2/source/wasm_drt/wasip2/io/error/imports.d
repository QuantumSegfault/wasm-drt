/++

+/
module wasm_drt.wasip2.io.error.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.io.error.common;


package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
struct Error_ {
  package(wasm_drt.wasip2) uint __handle = 0;

  pragma(inline, true)
  package(wasm_drt.wasip2) this(uint handle) @safe @nogc nothrow {
    __handle = handle;
  }

  
  pragma(inline, true) void witDrop() @trusted @nogc nothrow {
    if (!__handle) return; __import_drop(__handle); __handle = 0;
  }
  @wasmImport!("wasi:io/error@0.2.12", "[resource-drop]error")
  pragma(mangle, "__wit_import_wasi:io__error@0.2.12__:resource_drop:error")
  static private extern(C) void __import_drop(uint) @nogc nothrow;

  pragma(inline, true) void witFree() @safe @nogc nothrow {}
  pragma(inline, true) typeof(this) witClone() const @safe @nogc nothrow { return typeof(this)(__handle); }
  // TODO: make RAII? disable copy for the own

  Borrow borrow() => Borrow(__handle);
  alias borrow this;

  struct Borrow {
    package(wasm_drt.wasip2) uint __handle = 0;

    pragma(inline, true)
    package(wasm_drt.wasip2) this(uint handle) @safe @nogc nothrow {
      __handle = handle;
    }

    pragma(inline, true) void witFree() @safe @nogc nothrow {}
    pragma(inline, true)
    void witDrop() @trusted @nogc nothrow {
      if (!__handle) return; __import_drop(__handle); __handle = 0;
    }
    pragma(inline, true) Borrow witClone() const @safe @nogc nothrow { return Borrow(__handle); }
    
    /++

    +/
    WitString toDebugString() @trusted @nogc nothrow {
      align(size_t.sizeof) void[(2*size_t.sizeof)] _retArea = void;
      __import_toDebugString(this.__handle, _retArea.ptr);
      auto _len0 = *(cast(size_t*)(_retArea.ptr + size_t.sizeof));
      auto _ptr0 = _len0 ? cast(char*)(*(cast(void**)(_retArea.ptr + 0))) : null;
      auto _list1 = WitString(_ptr0[0.._len0]);
      auto _flush2 = _list1;
      return _flush2;
    }
    /// ditto
    @wasmImport!("wasi:io/error@0.2.12", "[method]error.to-debug-string")
    pragma(mangle, "__wit_import_wasi:io__error@0.2.12__:method:error.to_debug_string")
    static private extern(C) void __import_toDebugString(uint, void*) @nogc nothrow;
  }
}
