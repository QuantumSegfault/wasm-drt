/++

+/
module wasm_drt.wasip2.sockets.ip_name_lookup.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.sockets.ip_name_lookup.common;

static import wasm_drt.wasip2.io.poll.imports;
static import wasm_drt.wasip2.sockets.network.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Pollable = wasm_drt.wasip2.io.poll.imports.Pollable;

/++

+/
alias Network = wasm_drt.wasip2.sockets.network.imports.Network;

/++

+/
struct ResolveAddressStream {
  package(wasm_drt.wasip2) uint __handle = 0;

  pragma(inline, true)
  package(wasm_drt.wasip2) this(uint handle) @safe @nogc nothrow {
    __handle = handle;
  }

  
  pragma(inline, true) void witDrop() @trusted @nogc nothrow {
    if (!__handle) return; __import_drop(__handle); __handle = 0;
  }
  @wasmImport!("wasi:sockets/ip-name-lookup@0.2.12", "[resource-drop]resolve-address-stream")
  pragma(mangle, "__wit_import_wasi:sockets__ip_name_lookup@0.2.12__:resource_drop:resolve_address_stream")
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
    Result!(Option!(IpAddress), ErrorCode) resolveNextAddress() @trusted nothrow {
      align(2) void[22] _retArea = void;
      __import_resolveNextAddress(this.__handle, _retArea.ptr);
      Result!(Option!(IpAddress), ErrorCode) _result12 = void;
      bool _isErr12 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr12) {
        
        _result12 = Result!(Option!(IpAddress), ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 2)))));
      } else {
        Option!(IpAddress) _option10 = void;
        bool _isSome10 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 2)))) != 0;
        if (_isSome10) {
          wasm_drt.wasip2.sockets.network.imports.IpAddress _variant7 = void;
          auto _tag7 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)));
          alias _Tag7 = wasm_drt.wasip2.sockets.network.imports.IpAddress.Tag;
          final switch (cast(wasm_drt.wasip2.sockets.network.imports.IpAddress.Tag)_tag7) {
            case _Tag7.ipv4: {
              auto _tuple4 = wasm_drt.wasip2.sockets.network.imports.Ipv4Address(
              cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 6)))),
              cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 7)))),
              cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 8)))),
              cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 9)))),
              );
              auto _payload8 = _tuple4;
              _variant7 = wasm_drt.wasip2.sockets.network.imports.IpAddress.ipv4(_payload8);
              break;
            }
            case _Tag7.ipv6: {
              auto _tuple6 = wasm_drt.wasip2.sockets.network.imports.Ipv6Address(
              cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 6)))),
              cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 8)))),
              cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 10)))),
              cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 12)))),
              cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 14)))),
              cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 16)))),
              cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 18)))),
              cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 20)))),
              );
              auto _payload9 = _tuple6;
              _variant7 = wasm_drt.wasip2.sockets.network.imports.IpAddress.ipv6(_payload9);
              break;
            }
          }

          _option10 = Option!(IpAddress).makeSome(_variant7);
        } else {
          _option10 = Option!(IpAddress).makeNone;
        }

        _result12 = Result!(Option!(IpAddress), ErrorCode).makeOk(_option10);
      }
      auto _flush13 = _result12;
      return _flush13;
    }
    /// ditto
    @wasmImport!("wasi:sockets/ip-name-lookup@0.2.12", "[method]resolve-address-stream.resolve-next-address")
    pragma(mangle, "__wit_import_wasi:sockets__ip_name_lookup@0.2.12__:method:resolve_address_stream.resolve_next_address")
    static private extern(C) void __import_resolveNextAddress(uint, void*) nothrow;

    /++

    +/
    Pollable subscribe() @trusted nothrow {
      auto _ret = __import_subscribe(this.__handle);
      auto _handle0 = Pollable(_ret);
      return _handle0;
    }
    /// ditto
    @wasmImport!("wasi:sockets/ip-name-lookup@0.2.12", "[method]resolve-address-stream.subscribe")
    pragma(mangle, "__wit_import_wasi:sockets__ip_name_lookup@0.2.12__:method:resolve_address_stream.subscribe")
    static private extern(C) uint __import_subscribe(uint) nothrow;
  }
}

/++

+/
Result!(ResolveAddressStream, ErrorCode) resolveAddresses(Network.Borrow network, in WitString name) @trusted nothrow {
  align(4) void[8] _retArea = void;
  __import_resolveAddresses(network.__handle, cast(void*)(name.ptr), name.length, _retArea.ptr);
  Result!(ResolveAddressStream, ErrorCode) _result3 = void;
  bool _isErr3 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
  if (_isErr3) {
    
    _result3 = Result!(ResolveAddressStream, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)))));
  } else {
    auto _handle1 = ResolveAddressStream(*(cast(uint*)(_retArea.ptr + 4)));

    _result3 = Result!(ResolveAddressStream, ErrorCode).makeOk(_handle1);
  }
  auto _flush4 = _result3;
  return _flush4;
}
/// ditto
@wasmImport!("wasi:sockets/ip-name-lookup@0.2.12", "resolve-addresses")
pragma(mangle, "__wit_import_wasi:sockets__ip_name_lookup@0.2.12__resolve_addresses")
private extern(C) void __import_resolveAddresses(uint, void*, size_t, void*) nothrow;
