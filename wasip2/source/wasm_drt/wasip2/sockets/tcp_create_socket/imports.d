/++

+/
module wasm_drt.wasip2.sockets.tcp_create_socket.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.sockets.tcp_create_socket.common;

static import wasm_drt.wasip2.sockets.network.imports;
static import wasm_drt.wasip2.sockets.tcp.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Network = wasm_drt.wasip2.sockets.network.imports.Network;

/++

+/
alias TcpSocket = wasm_drt.wasip2.sockets.tcp.imports.TcpSocket;

/++

+/
Result!(TcpSocket, ErrorCode) createTcpSocket(IpAddressFamily addressFamily) @trusted @nogc nothrow {
  align(4) void[8] _retArea = void;
  __import_createTcpSocket(cast(uint)(addressFamily), _retArea.ptr);
  Result!(TcpSocket, ErrorCode) _result3 = void;
  bool _isErr3 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
  if (_isErr3) {
    
    _result3 = Result!(TcpSocket, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)))));
  } else {
    auto _handle1 = TcpSocket(*(cast(uint*)(_retArea.ptr + 4)));

    _result3 = Result!(TcpSocket, ErrorCode).makeOk(_handle1);
  }
  auto _flush4 = _result3;
  return _flush4;
}
/// ditto
@wasmImport!("wasi:sockets/tcp-create-socket@0.2.12", "create-tcp-socket")
pragma(mangle, "__wit_import_wasi:sockets__tcp_create_socket@0.2.12__create_tcp_socket")
private extern(C) void __import_createTcpSocket(uint, void*) @nogc nothrow;
