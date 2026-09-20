/++

+/
module wasm_drt.wasip2.sockets.udp_create_socket.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.sockets.udp_create_socket.common;

static import wasm_drt.wasip2.sockets.network.imports;
static import wasm_drt.wasip2.sockets.udp.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Network = wasm_drt.wasip2.sockets.network.imports.Network;

/++

+/
alias UdpSocket = wasm_drt.wasip2.sockets.udp.imports.UdpSocket;

/++

+/
Result!(UdpSocket, ErrorCode) createUdpSocket(IpAddressFamily addressFamily) @trusted nothrow {
  align(4) void[8] _retArea = void;
  __import_createUdpSocket(cast(uint)(addressFamily), _retArea.ptr);
  Result!(UdpSocket, ErrorCode) _result3 = void;
  bool _isErr3 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
  if (_isErr3) {
    
    _result3 = Result!(UdpSocket, ErrorCode).makeErr(cast(wasm_drt.wasip2.sockets.network.imports.ErrorCode)(cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)))));
  } else {
    auto _handle1 = UdpSocket(*(cast(uint*)(_retArea.ptr + 4)));

    _result3 = Result!(UdpSocket, ErrorCode).makeOk(_handle1);
  }
  auto _flush4 = _result3;
  return _flush4;
}
/// ditto
@wasmImport!("wasi:sockets/udp-create-socket@0.2.12", "create-udp-socket")
pragma(mangle, "__wit_import_wasi:sockets__udp_create_socket@0.2.12__create_udp_socket")
private extern(C) void __import_createUdpSocket(uint, void*) nothrow;
