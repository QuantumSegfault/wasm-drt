/++

+/
module wasm_drt.wasip2.io.poll.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.io.poll.common;


package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
struct Pollable {
  package(wasm_drt.wasip2) uint __handle = 0;

  pragma(inline, true)
  package(wasm_drt.wasip2) this(uint handle) @safe @nogc nothrow {
    __handle = handle;
  }

  
  pragma(inline, true) void witDrop() @trusted @nogc nothrow {
    if (!__handle) return; __import_drop(__handle); __handle = 0;
  }
  @wasmImport!("wasi:io/poll@0.2.12", "[resource-drop]pollable")
  pragma(mangle, "__wit_import_wasi:io__poll@0.2.12__:resource_drop:pollable")
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
    bool ready() @trusted nothrow {
      auto _ret = __import_ready(this.__handle);
      return (_ret) != 0;
    }
    /// ditto
    @wasmImport!("wasi:io/poll@0.2.12", "[method]pollable.ready")
    pragma(mangle, "__wit_import_wasi:io__poll@0.2.12__:method:pollable.ready")
    static private extern(C) uint __import_ready(uint) nothrow;

    /++

    +/
    void block() @trusted nothrow {
      __import_block(this.__handle);
    }
    /// ditto
    @wasmImport!("wasi:io/poll@0.2.12", "[method]pollable.block")
    pragma(mangle, "__wit_import_wasi:io__poll@0.2.12__:method:pollable.block")
    static private extern(C) void __import_block(uint) nothrow;
  }
}

/++

+/
WitList!(uint) poll(in WitList!(Pollable.Borrow) in_) @trusted nothrow {
  align(size_t.sizeof) void[(2*size_t.sizeof)] _retArea = void;
  __import_poll(cast(void*)(in_.ptr), in_.length, _retArea.ptr);
  auto _len0 = *(cast(size_t*)(_retArea.ptr + size_t.sizeof));
  auto _ptr0 = _len0 ? cast(uint*)(*(cast(void**)(_retArea.ptr + 0))) : null;
  auto _list1 = WitList!(uint)(_ptr0[0.._len0]);
  auto _flush2 = _list1;
  return _flush2;
}
/// ditto
@wasmImport!("wasi:io/poll@0.2.12", "poll")
pragma(mangle, "__wit_import_wasi:io__poll@0.2.12__poll")
private extern(C) void __import_poll(void*, size_t, void*) nothrow;
