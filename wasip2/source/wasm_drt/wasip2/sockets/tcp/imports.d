/++

+/
module wasm_drt.wasip2.sockets.tcp.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.sockets.tcp.common;

static import wasm_drt.wasip2.io.poll.imports;
static import wasm_drt.wasip2.io.streams.imports;
static import wasm_drt.wasip2.clocks.monotonic_clock.imports;
static import wasm_drt.wasip2.sockets.network.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias InputStream = wasm_drt.wasip2.io.streams.imports.InputStream;

/++

+/
alias OutputStream = wasm_drt.wasip2.io.streams.imports.OutputStream;

/++

+/
alias Pollable = wasm_drt.wasip2.io.poll.imports.Pollable;

/++

+/
alias Network = wasm_drt.wasip2.sockets.network.imports.Network;

/++

+/
struct TcpSocket {
  package(wasm_drt.wasip2) uint __handle = 0;

  pragma(inline, true)
  package(wasm_drt.wasip2) this(uint handle) @safe @nogc nothrow {
    __handle = handle;
  }

  
  pragma(inline, true) void witDrop() @trusted @nogc nothrow {
    if (!__handle) return; __import_drop(__handle); __handle = 0;
  }
  @wasmImport!("wasi:sockets/tcp@0.2.12", "[resource-drop]tcp-socket")
  pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:resource_drop:tcp_socket")
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
    Result!(void, ErrorCode) startBind(Network.Borrow network, in IpSocketAddress localAddress) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      uint _variantPart4 = void;
      uint _variantPart5 = void;
      uint _variantPart6 = void;
      uint _variantPart7 = void;
      uint _variantPart8 = void;
      uint _variantPart9 = void;
      uint _variantPart10 = void;
      uint _variantPart11 = void;
      uint _variantPart12 = void;
      uint _variantPart13 = void;
      uint _variantPart14 = void;
      uint _variantPart15 = void;
      alias _Tag16 = wasm_drt.wasip2.sockets.network.imports.IpSocketAddress.Tag;
      final switch (localAddress.tag) {
        case _Tag16.ipv4: {
          const ref wasm_drt.wasip2.sockets.network.imports.Ipv4SocketAddress _payload1 = localAddress.getIpv4();
          _variantPart4 = 0;
          _variantPart5 = cast(uint)(_payload1.port);
          _variantPart6 = cast(uint)(_payload1.address[0]);
          _variantPart7 = cast(uint)(_payload1.address[1]);
          _variantPart8 = cast(uint)(_payload1.address[2]);
          _variantPart9 = cast(uint)(_payload1.address[3]);
          _variantPart10 = 0;
          _variantPart11 = 0;
          _variantPart12 = 0;
          _variantPart13 = 0;
          _variantPart14 = 0;
          _variantPart15 = 0;
          break;
        }
        case _Tag16.ipv6: {
          const ref wasm_drt.wasip2.sockets.network.imports.Ipv6SocketAddress _payload3 = localAddress.getIpv6();
          _variantPart4 = 1;
          _variantPart5 = cast(uint)(_payload3.port);
          _variantPart6 = _payload3.flowInfo;
          _variantPart7 = cast(uint)(_payload3.address[0]);
          _variantPart8 = cast(uint)(_payload3.address[1]);
          _variantPart9 = cast(uint)(_payload3.address[2]);
          _variantPart10 = cast(uint)(_payload3.address[3]);
          _variantPart11 = cast(uint)(_payload3.address[4]);
          _variantPart12 = cast(uint)(_payload3.address[5]);
          _variantPart13 = cast(uint)(_payload3.address[6]);
          _variantPart14 = cast(uint)(_payload3.address[7]);
          _variantPart15 = _payload3.scopeId;
          break;
        }
      }
      __import_startBind(this.__handle, network.__handle, _variantPart4, _variantPart5, _variantPart6, _variantPart7, _variantPart8, _variantPart9, _variantPart10, _variantPart11, _variantPart12, _variantPart13, _variantPart14, _variantPart15, _retArea.ptr);
      Result!(void, ErrorCode) _result19 = void;
      bool _isErr19 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr19) {
        
        _result19 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result19 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush20 = _result19;
      return _flush20;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.start-bind")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.start_bind")
    static private extern(C) void __import_startBind(uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) finishBind() @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_finishBind(this.__handle, _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.finish-bind")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.finish_bind")
    static private extern(C) void __import_finishBind(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) startConnect(Network.Borrow network, in IpSocketAddress remoteAddress) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      uint _variantPart4 = void;
      uint _variantPart5 = void;
      uint _variantPart6 = void;
      uint _variantPart7 = void;
      uint _variantPart8 = void;
      uint _variantPart9 = void;
      uint _variantPart10 = void;
      uint _variantPart11 = void;
      uint _variantPart12 = void;
      uint _variantPart13 = void;
      uint _variantPart14 = void;
      uint _variantPart15 = void;
      alias _Tag16 = wasm_drt.wasip2.sockets.network.imports.IpSocketAddress.Tag;
      final switch (remoteAddress.tag) {
        case _Tag16.ipv4: {
          const ref wasm_drt.wasip2.sockets.network.imports.Ipv4SocketAddress _payload1 = remoteAddress.getIpv4();
          _variantPart4 = 0;
          _variantPart5 = cast(uint)(_payload1.port);
          _variantPart6 = cast(uint)(_payload1.address[0]);
          _variantPart7 = cast(uint)(_payload1.address[1]);
          _variantPart8 = cast(uint)(_payload1.address[2]);
          _variantPart9 = cast(uint)(_payload1.address[3]);
          _variantPart10 = 0;
          _variantPart11 = 0;
          _variantPart12 = 0;
          _variantPart13 = 0;
          _variantPart14 = 0;
          _variantPart15 = 0;
          break;
        }
        case _Tag16.ipv6: {
          const ref wasm_drt.wasip2.sockets.network.imports.Ipv6SocketAddress _payload3 = remoteAddress.getIpv6();
          _variantPart4 = 1;
          _variantPart5 = cast(uint)(_payload3.port);
          _variantPart6 = _payload3.flowInfo;
          _variantPart7 = cast(uint)(_payload3.address[0]);
          _variantPart8 = cast(uint)(_payload3.address[1]);
          _variantPart9 = cast(uint)(_payload3.address[2]);
          _variantPart10 = cast(uint)(_payload3.address[3]);
          _variantPart11 = cast(uint)(_payload3.address[4]);
          _variantPart12 = cast(uint)(_payload3.address[5]);
          _variantPart13 = cast(uint)(_payload3.address[6]);
          _variantPart14 = cast(uint)(_payload3.address[7]);
          _variantPart15 = _payload3.scopeId;
          break;
        }
      }
      __import_startConnect(this.__handle, network.__handle, _variantPart4, _variantPart5, _variantPart6, _variantPart7, _variantPart8, _variantPart9, _variantPart10, _variantPart11, _variantPart12, _variantPart13, _variantPart14, _variantPart15, _retArea.ptr);
      Result!(void, ErrorCode) _result19 = void;
      bool _isErr19 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr19) {
        
        _result19 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result19 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush20 = _result19;
      return _flush20;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.start-connect")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.start_connect")
    static private extern(C) void __import_startConnect(uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, void*) @nogc nothrow;

    /++

    +/
    Result!(Tuple!(InputStream, OutputStream), ErrorCode) finishConnect() @trusted @nogc nothrow {
      align(4) void[12] _retArea = void;
      __import_finishConnect(this.__handle, _retArea.ptr);
      Result!(Tuple!(InputStream, OutputStream), ErrorCode) _result5 = void;
      bool _isErr5 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr5) {
        
        _result5 = Result!(Tuple!(InputStream, OutputStream), ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)))));
      } else {
        auto _handle1 = InputStream(*(cast(uint*)(_retArea.ptr + 4)));
        auto _handle2 = OutputStream(*(cast(uint*)(_retArea.ptr + 8)));
        auto _tuple3 = Tuple!(InputStream, OutputStream)(
        _handle1,
        _handle2,
        );

        _result5 = Result!(Tuple!(InputStream, OutputStream), ErrorCode).makeOk(_tuple3);
      }
      auto _flush6 = _result5;
      return _flush6;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.finish-connect")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.finish_connect")
    static private extern(C) void __import_finishConnect(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) startListen() @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_startListen(this.__handle, _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.start-listen")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.start_listen")
    static private extern(C) void __import_startListen(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) finishListen() @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_finishListen(this.__handle, _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.finish-listen")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.finish_listen")
    static private extern(C) void __import_finishListen(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(Tuple!(TcpSocket, InputStream, OutputStream), ErrorCode) accept() @trusted @nogc nothrow {
      align(4) void[16] _retArea = void;
      __import_accept(this.__handle, _retArea.ptr);
      Result!(Tuple!(TcpSocket, InputStream, OutputStream), ErrorCode) _result6 = void;
      bool _isErr6 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr6) {
        
        _result6 = Result!(Tuple!(TcpSocket, InputStream, OutputStream), ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)))));
      } else {
        auto _handle1 = TcpSocket(*(cast(uint*)(_retArea.ptr + 4)));
        auto _handle2 = InputStream(*(cast(uint*)(_retArea.ptr + 8)));
        auto _handle3 = OutputStream(*(cast(uint*)(_retArea.ptr + 12)));
        auto _tuple4 = Tuple!(TcpSocket, InputStream, OutputStream)(
        _handle1,
        _handle2,
        _handle3,
        );

        _result6 = Result!(Tuple!(TcpSocket, InputStream, OutputStream), ErrorCode).makeOk(_tuple4);
      }
      auto _flush7 = _result6;
      return _flush7;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.accept")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.accept")
    static private extern(C) void __import_accept(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(IpSocketAddress, ErrorCode) localAddress() @trusted @nogc nothrow {
      align(4) void[36] _retArea = void;
      __import_localAddress(this.__handle, _retArea.ptr);
      Result!(IpSocketAddress, ErrorCode) _result11 = void;
      bool _isErr11 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr11) {
        
        _result11 = Result!(IpSocketAddress, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)))));
      } else {
        wasm_drt.wasip2.sockets.network.imports.IpSocketAddress _variant7 = void;
        auto _tag7 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)));
        alias _Tag7 = wasm_drt.wasip2.sockets.network.imports.IpSocketAddress.Tag;
        final switch (cast(wasm_drt.wasip2.sockets.network.imports.IpSocketAddress.Tag)_tag7) {
          case _Tag7.ipv4: {
            auto _tuple2 = wasm_drt.wasip2.sockets.network.imports.Ipv4Address(
            cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 10)))),
            cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 11)))),
            cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 12)))),
            cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 13)))),
            );
            wasm_drt.wasip2.sockets.network.imports.Ipv4SocketAddress _record3 = {
              port: cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 8)))),
              address: _tuple2,
            };
            auto _payload8 = _record3;
            _variant7 = wasm_drt.wasip2.sockets.network.imports.IpSocketAddress.ipv4(_payload8);
            break;
          }
          case _Tag7.ipv6: {
            auto _tuple5 = wasm_drt.wasip2.sockets.network.imports.Ipv6Address(
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 16)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 18)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 20)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 22)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 24)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 26)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 28)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 30)))),
            );
            wasm_drt.wasip2.sockets.network.imports.Ipv6SocketAddress _record6 = {
              port: cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 8)))),
              flowInfo: *(cast(uint*)(_retArea.ptr + 12)),
              address: _tuple5,
              scopeId: *(cast(uint*)(_retArea.ptr + 32)),
            };
            auto _payload9 = _record6;
            _variant7 = wasm_drt.wasip2.sockets.network.imports.IpSocketAddress.ipv6(_payload9);
            break;
          }
        }

        _result11 = Result!(IpSocketAddress, ErrorCode).makeOk(_variant7);
      }
      auto _flush12 = _result11;
      return _flush12;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.local-address")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.local_address")
    static private extern(C) void __import_localAddress(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(IpSocketAddress, ErrorCode) remoteAddress() @trusted @nogc nothrow {
      align(4) void[36] _retArea = void;
      __import_remoteAddress(this.__handle, _retArea.ptr);
      Result!(IpSocketAddress, ErrorCode) _result11 = void;
      bool _isErr11 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr11) {
        
        _result11 = Result!(IpSocketAddress, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)))));
      } else {
        wasm_drt.wasip2.sockets.network.imports.IpSocketAddress _variant7 = void;
        auto _tag7 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)));
        alias _Tag7 = wasm_drt.wasip2.sockets.network.imports.IpSocketAddress.Tag;
        final switch (cast(wasm_drt.wasip2.sockets.network.imports.IpSocketAddress.Tag)_tag7) {
          case _Tag7.ipv4: {
            auto _tuple2 = wasm_drt.wasip2.sockets.network.imports.Ipv4Address(
            cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 10)))),
            cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 11)))),
            cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 12)))),
            cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 13)))),
            );
            wasm_drt.wasip2.sockets.network.imports.Ipv4SocketAddress _record3 = {
              port: cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 8)))),
              address: _tuple2,
            };
            auto _payload8 = _record3;
            _variant7 = wasm_drt.wasip2.sockets.network.imports.IpSocketAddress.ipv4(_payload8);
            break;
          }
          case _Tag7.ipv6: {
            auto _tuple5 = wasm_drt.wasip2.sockets.network.imports.Ipv6Address(
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 16)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 18)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 20)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 22)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 24)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 26)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 28)))),
            cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 30)))),
            );
            wasm_drt.wasip2.sockets.network.imports.Ipv6SocketAddress _record6 = {
              port: cast(ushort)(cast(uint)(*(cast(ushort*)(_retArea.ptr + 8)))),
              flowInfo: *(cast(uint*)(_retArea.ptr + 12)),
              address: _tuple5,
              scopeId: *(cast(uint*)(_retArea.ptr + 32)),
            };
            auto _payload9 = _record6;
            _variant7 = wasm_drt.wasip2.sockets.network.imports.IpSocketAddress.ipv6(_payload9);
            break;
          }
        }

        _result11 = Result!(IpSocketAddress, ErrorCode).makeOk(_variant7);
      }
      auto _flush12 = _result11;
      return _flush12;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.remote-address")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.remote_address")
    static private extern(C) void __import_remoteAddress(uint, void*) @nogc nothrow;

    /++

    +/
    bool isListening() @trusted @nogc nothrow {
      auto _ret = __import_isListening(this.__handle);
      return (_ret) != 0;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.is-listening")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.is_listening")
    static private extern(C) uint __import_isListening(uint) @nogc nothrow;

    /++

    +/
    IpAddressFamily addressFamily() @trusted @nogc nothrow {
      auto _ret = __import_addressFamily(this.__handle);
      return cast(wasm_drt.wasip2.sockets.network.imports.IpAddressFamily)(_ret);
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.address-family")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.address_family")
    static private extern(C) uint __import_addressFamily(uint) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) setListenBacklogSize(ulong value) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_setListenBacklogSize(this.__handle, value, _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.set-listen-backlog-size")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.set_listen_backlog_size")
    static private extern(C) void __import_setListenBacklogSize(uint, ulong, void*) @nogc nothrow;

    /++

    +/
    Result!(bool, ErrorCode) keepAliveEnabled() @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_keepAliveEnabled(this.__handle, _retArea.ptr);
      Result!(bool, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(bool, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(bool, ErrorCode).makeOk((cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))) != 0);
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.keep-alive-enabled")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.keep_alive_enabled")
    static private extern(C) void __import_keepAliveEnabled(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) setKeepAliveEnabled(bool value) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_setKeepAliveEnabled(this.__handle, cast(uint)(value), _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.set-keep-alive-enabled")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.set_keep_alive_enabled")
    static private extern(C) void __import_setKeepAliveEnabled(uint, uint, void*) @nogc nothrow;

    /++

    +/
    Result!(Duration, ErrorCode) keepAliveIdleTime() @trusted @nogc nothrow {
      align(8) void[16] _retArea = void;
      __import_keepAliveIdleTime(this.__handle, _retArea.ptr);
      Result!(Duration, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(Duration, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 8)))));
      } else {
        
        _result2 = Result!(Duration, ErrorCode).makeOk(*(cast(ulong*)(_retArea.ptr + 8)));
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.keep-alive-idle-time")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.keep_alive_idle_time")
    static private extern(C) void __import_keepAliveIdleTime(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) setKeepAliveIdleTime(Duration value) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_setKeepAliveIdleTime(this.__handle, value, _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.set-keep-alive-idle-time")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.set_keep_alive_idle_time")
    static private extern(C) void __import_setKeepAliveIdleTime(uint, ulong, void*) @nogc nothrow;

    /++

    +/
    Result!(Duration, ErrorCode) keepAliveInterval() @trusted @nogc nothrow {
      align(8) void[16] _retArea = void;
      __import_keepAliveInterval(this.__handle, _retArea.ptr);
      Result!(Duration, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(Duration, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 8)))));
      } else {
        
        _result2 = Result!(Duration, ErrorCode).makeOk(*(cast(ulong*)(_retArea.ptr + 8)));
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.keep-alive-interval")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.keep_alive_interval")
    static private extern(C) void __import_keepAliveInterval(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) setKeepAliveInterval(Duration value) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_setKeepAliveInterval(this.__handle, value, _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.set-keep-alive-interval")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.set_keep_alive_interval")
    static private extern(C) void __import_setKeepAliveInterval(uint, ulong, void*) @nogc nothrow;

    /++

    +/
    Result!(uint, ErrorCode) keepAliveCount() @trusted @nogc nothrow {
      align(4) void[8] _retArea = void;
      __import_keepAliveCount(this.__handle, _retArea.ptr);
      Result!(uint, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(uint, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)))));
      } else {
        
        _result2 = Result!(uint, ErrorCode).makeOk(*(cast(uint*)(_retArea.ptr + 4)));
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.keep-alive-count")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.keep_alive_count")
    static private extern(C) void __import_keepAliveCount(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) setKeepAliveCount(uint value) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_setKeepAliveCount(this.__handle, value, _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.set-keep-alive-count")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.set_keep_alive_count")
    static private extern(C) void __import_setKeepAliveCount(uint, uint, void*) @nogc nothrow;

    /++

    +/
    Result!(ubyte, ErrorCode) hopLimit() @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_hopLimit(this.__handle, _retArea.ptr);
      Result!(ubyte, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(ubyte, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(ubyte, ErrorCode).makeOk(cast(ubyte)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.hop-limit")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.hop_limit")
    static private extern(C) void __import_hopLimit(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) setHopLimit(ubyte value) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_setHopLimit(this.__handle, cast(uint)(value), _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.set-hop-limit")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.set_hop_limit")
    static private extern(C) void __import_setHopLimit(uint, uint, void*) @nogc nothrow;

    /++

    +/
    Result!(ulong, ErrorCode) receiveBufferSize() @trusted @nogc nothrow {
      align(8) void[16] _retArea = void;
      __import_receiveBufferSize(this.__handle, _retArea.ptr);
      Result!(ulong, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(ulong, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 8)))));
      } else {
        
        _result2 = Result!(ulong, ErrorCode).makeOk(*(cast(ulong*)(_retArea.ptr + 8)));
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.receive-buffer-size")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.receive_buffer_size")
    static private extern(C) void __import_receiveBufferSize(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) setReceiveBufferSize(ulong value) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_setReceiveBufferSize(this.__handle, value, _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.set-receive-buffer-size")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.set_receive_buffer_size")
    static private extern(C) void __import_setReceiveBufferSize(uint, ulong, void*) @nogc nothrow;

    /++

    +/
    Result!(ulong, ErrorCode) sendBufferSize() @trusted @nogc nothrow {
      align(8) void[16] _retArea = void;
      __import_sendBufferSize(this.__handle, _retArea.ptr);
      Result!(ulong, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(ulong, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 8)))));
      } else {
        
        _result2 = Result!(ulong, ErrorCode).makeOk(*(cast(ulong*)(_retArea.ptr + 8)));
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.send-buffer-size")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.send_buffer_size")
    static private extern(C) void __import_sendBufferSize(uint, void*) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) setSendBufferSize(ulong value) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_setSendBufferSize(this.__handle, value, _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.set-send-buffer-size")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.set_send_buffer_size")
    static private extern(C) void __import_setSendBufferSize(uint, ulong, void*) @nogc nothrow;

    /++

    +/
    Pollable subscribe() @trusted @nogc nothrow {
      auto _ret = __import_subscribe(this.__handle);
      auto _handle0 = Pollable(_ret);
      return _handle0;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.subscribe")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.subscribe")
    static private extern(C) uint __import_subscribe(uint) @nogc nothrow;

    /++

    +/
    Result!(void, ErrorCode) shutdown(ShutdownType shutdownType) @trusted @nogc nothrow {
      align(1) void[2] _retArea = void;
      __import_shutdown(this.__handle, cast(uint)(shutdownType), _retArea.ptr);
      Result!(void, ErrorCode) _result2 = void;
      bool _isErr2 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr2) {
        
        _result2 = Result!(void, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 1)))));
      } else {
        
        _result2 = Result!(void, ErrorCode).makeOk();
      }
      auto _flush3 = _result2;
      return _flush3;
    }
    /// ditto
    @wasmImport!("wasi:sockets/tcp@0.2.12", "[method]tcp-socket.shutdown")
    pragma(mangle, "__wit_import_wasi:sockets__tcp@0.2.12__:method:tcp_socket.shutdown")
    static private extern(C) void __import_shutdown(uint, uint, void*) @nogc nothrow;
  }
}
