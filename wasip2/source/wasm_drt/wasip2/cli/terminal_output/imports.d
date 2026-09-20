/++
Terminal output.

In the future, this may include functions for querying the terminal
size, being notified of terminal size changes, querying supported
features, and so on.
+/
module wasm_drt.wasip2.cli.terminal_output.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.cli.terminal_output.common;


package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++
The output side of a terminal.
+/
struct TerminalOutput {
  package(wasm_drt.wasip2) uint __handle = 0;

  pragma(inline, true)
  package(wasm_drt.wasip2) this(uint handle) @safe @nogc nothrow {
    __handle = handle;
  }

  
  pragma(inline, true) void witDrop() @trusted @nogc nothrow {
    if (!__handle) return; __import_drop(__handle); __handle = 0;
  }
  @wasmImport!("wasi:cli/terminal-output@0.2.12", "[resource-drop]terminal-output")
  pragma(mangle, "__wit_import_wasi:cli__terminal_output@0.2.12__:resource_drop:terminal_output")
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
