/++

+/
module wasm_drt.wasip2.clocks.monotonic_clock.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.clocks.monotonic_clock.common;

static import wasm_drt.wasip2.io.poll.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Pollable = wasm_drt.wasip2.io.poll.imports.Pollable;

/++

+/
Instant now() @trusted @nogc nothrow {
  auto _ret = __import_now();
  return _ret;
}
/// ditto
@wasmImport!("wasi:clocks/monotonic-clock@0.2.12", "now")
pragma(mangle, "__wit_import_wasi:clocks__monotonic_clock@0.2.12__now")
private extern(C) ulong __import_now() @nogc nothrow;

/++

+/
Duration resolution() @trusted @nogc nothrow {
  auto _ret = __import_resolution();
  return _ret;
}
/// ditto
@wasmImport!("wasi:clocks/monotonic-clock@0.2.12", "resolution")
pragma(mangle, "__wit_import_wasi:clocks__monotonic_clock@0.2.12__resolution")
private extern(C) ulong __import_resolution() @nogc nothrow;

/++

+/
Pollable subscribeInstant(Instant when) @trusted @nogc nothrow {
  auto _ret = __import_subscribeInstant(when);
  auto _handle0 = Pollable(_ret);
  return _handle0;
}
/// ditto
@wasmImport!("wasi:clocks/monotonic-clock@0.2.12", "subscribe-instant")
pragma(mangle, "__wit_import_wasi:clocks__monotonic_clock@0.2.12__subscribe_instant")
private extern(C) uint __import_subscribeInstant(ulong) @nogc nothrow;

/++

+/
Pollable subscribeDuration(Duration when) @trusted @nogc nothrow {
  auto _ret = __import_subscribeDuration(when);
  auto _handle0 = Pollable(_ret);
  return _handle0;
}
/// ditto
@wasmImport!("wasi:clocks/monotonic-clock@0.2.12", "subscribe-duration")
pragma(mangle, "__wit_import_wasi:clocks__monotonic_clock@0.2.12__subscribe_duration")
private extern(C) uint __import_subscribeDuration(ulong) @nogc nothrow;
