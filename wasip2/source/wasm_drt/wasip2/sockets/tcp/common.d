/++

+/
module wasm_drt.wasip2.sockets.tcp.common;


import wasm_drt.wasip2.wit;

static import wasm_drt.wasip2.io.poll.common;
static import wasm_drt.wasip2.io.streams.common;
static import wasm_drt.wasip2.clocks.monotonic_clock.common;
static import wasm_drt.wasip2.sockets.network.common;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Duration = wasm_drt.wasip2.clocks.monotonic_clock.common.Duration;

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
enum ShutdownType : ubyte {
  /++

  +/
  receive,

  /++

  +/
  send,

  /++

  +/
  both,
}