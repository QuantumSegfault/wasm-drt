/++

+/
module wasm_drt.wasip2.clocks.wall_clock.common;


import wasm_drt.wasip2.wit;


package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
struct Datetime {
  /++

  +/
  ulong seconds;

  /++

  +/
  uint nanoseconds;

  void witFree() @nogc nothrow {
  }

  void witDrop() @nogc nothrow {
  }

  Datetime witClone() const @nogc nothrow {
    Datetime clone = void;
    clone.seconds = this.seconds.witClone;
    clone.nanoseconds = this.nanoseconds.witClone;
    return clone;
  }
}
