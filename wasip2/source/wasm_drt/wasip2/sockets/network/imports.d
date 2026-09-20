/++

+/
module wasm_drt.wasip2.sockets.network.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.sockets.network.common;

static import wasm_drt.wasip2.io.error.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Error_ = wasm_drt.wasip2.io.error.imports.Error_;

/++

+/
struct Network {
  package(wasm_drt.wasip2) uint __handle = 0;

  pragma(inline, true)
  package(wasm_drt.wasip2) this(uint handle) @safe @nogc nothrow {
    __handle = handle;
  }

  
  pragma(inline, true) void witDrop() @trusted @nogc nothrow {
    if (!__handle) return; __import_drop(__handle); __handle = 0;
  }
  @wasmImport!("wasi:sockets/network@0.2.12", "[resource-drop]network")
  pragma(mangle, "__wit_import_wasi:sockets__network@0.2.12__:resource_drop:network")
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
  }
}

/++

+/
Option!(ErrorCode) networkErrorCode(Error_.Borrow err) @trusted nothrow {
  align(1) void[2] _retArea = void;
  __import_networkErrorCode(err.__handle, _retArea.ptr);
  Option!(ErrorCode) _option2 = void;
  bool _isSome2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
  if (_isSome2) {
    
    _option2 = Option!(ErrorCode).makeSome(cast(ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
  } else {
    _option2 = Option!(ErrorCode).makeNone;
  }
  auto _flush3 = _option2;
  return _flush3;
}
/// ditto
@wasmImport!("wasi:sockets/network@0.2.12", "network-error-code")
pragma(mangle, "__wit_import_wasi:sockets__network@0.2.12__network_error_code")
private extern(C) void __import_networkErrorCode(uint, void*) nothrow;
