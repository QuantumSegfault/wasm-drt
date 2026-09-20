/++

+/
module wasm_drt.wasip2.sockets.udp.common;


import wasm_drt.wasip2.wit;

static import wasm_drt.wasip2.io.poll.common;
static import wasm_drt.wasip2.sockets.network.common;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias ErrorCode = wasm_drt.wasip2.sockets.network.common.ErrorCode;

/++

+/
alias IpSocketAddress = wasm_drt.wasip2.sockets.network.common.IpSocketAddress;

/++

+/
alias IpAddressFamily = wasm_drt.wasip2.sockets.network.common.IpAddressFamily;

/++

+/
struct IncomingDatagram {
  /++

  +/
  WitList!(ubyte) data;

  /++

  +/
  IpSocketAddress remoteAddress;

  void witFree() @nogc nothrow {
    data.witFree;
  }

  void witDrop() @nogc nothrow {
  }

  IncomingDatagram witClone() const @nogc nothrow {
    IncomingDatagram clone = void;
    clone.data = this.data.witClone;
    clone.remoteAddress = this.remoteAddress.witClone;
    return clone;
  }
}

/++

+/
struct OutgoingDatagram {
  /++

  +/
  WitList!(ubyte) data;

  /++

  +/
  Option!(IpSocketAddress) remoteAddress;

  void witFree() @nogc nothrow {
    data.witFree;
  }

  void witDrop() @nogc nothrow {
  }

  OutgoingDatagram witClone() const @nogc nothrow {
    OutgoingDatagram clone = void;
    clone.data = this.data.witClone;
    clone.remoteAddress = this.remoteAddress.witClone;
    return clone;
  }
}
