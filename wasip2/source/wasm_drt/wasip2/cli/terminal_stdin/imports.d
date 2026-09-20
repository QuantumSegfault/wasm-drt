/++
An interface providing an optional `terminal-input` for stdin as a
link-time authority.
+/
module wasm_drt.wasip2.cli.terminal_stdin.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.cli.terminal_stdin.common;

static import wasm_drt.wasip2.cli.terminal_input.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias TerminalInput = wasm_drt.wasip2.cli.terminal_input.imports.TerminalInput;

/++
If stdin is connected to a terminal, return a `terminal-input` handle
allowing further interaction with it.
+/
Option!(TerminalInput) getTerminalStdin() @trusted nothrow {
  align(4) void[8] _retArea = void;
  __import_getTerminalStdin(_retArea.ptr);
  Option!(TerminalInput) _option3 = void;
  bool _isSome3 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
  if (_isSome3) {
    auto _handle2 = TerminalInput(*(cast(uint*)(_retArea.ptr + 4)));

    _option3 = Option!(TerminalInput).makeSome(_handle2);
  } else {
    _option3 = Option!(TerminalInput).makeNone;
  }
  auto _flush4 = _option3;
  return _flush4;
}
/// ditto
@wasmImport!("wasi:cli/terminal-stdin@0.2.12", "get-terminal-stdin")
pragma(mangle, "__wit_import_wasi:cli__terminal_stdin@0.2.12__get_terminal_stdin")
private extern(C) void __import_getTerminalStdin(void*) nothrow;
