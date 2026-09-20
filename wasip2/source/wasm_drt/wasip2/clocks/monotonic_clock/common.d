/++

+/
module wasm_drt.wasip2.clocks.monotonic_clock.common;


import wasm_drt.wasip2.wit;

static import wasm_drt.wasip2.io.poll.common;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Instant = ulong;

/++

+/
alias Duration = ulong;
