/++
An interface providing an optional `terminal-output` for stdout as a
link-time authority.
+/
module wasm_drt.wasip2.cli.terminal_stdout.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.cli.terminal_stdout.common;

static import wasm_drt.wasip2.cli.terminal_output.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias TerminalOutput = wasm_drt.wasip2.cli.terminal_output.imports.TerminalOutput;

/++
If stdout is connected to a terminal, return a `terminal-output` handle
allowing further interaction with it.
+/
Option!(TerminalOutput) getTerminalStdout() @trusted @nogc nothrow {
  align(4) void[8] _retArea = void;
  __import_getTerminalStdout(_retArea.ptr);
  Option!(TerminalOutput) _option3 = void;
  bool _isSome3 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
  if (_isSome3) {
    auto _handle2 = TerminalOutput(*(cast(uint*)(_retArea.ptr + 4)));

    _option3 = Option!(TerminalOutput).makeSome(_handle2);
  } else {
    _option3 = Option!(TerminalOutput).makeNone;
  }
  auto _flush4 = _option3;
  return _flush4;
}
/// ditto
@wasmImport!("wasi:cli/terminal-stdout@0.2.12", "get-terminal-stdout")
pragma(mangle, "__wit_import_wasi:cli__terminal_stdout@0.2.12__get_terminal_stdout")
private extern(C) void __import_getTerminalStdout(void*) @nogc nothrow;
