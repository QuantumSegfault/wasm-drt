/++

+/
module wasm_drt.wasip2.cli.exports;

import wasm_drt.wasip2.wit;


public import wasm_drt.wasip2.cli.run.exports;


private alias AliasSeq(T...) = T;
template Exports(Impl...) {

  alias FilteredImpl = wasm_drt.wasip2.wit.findWitExports!Impl;
  alias InterfaceExports = AliasSeq!(
    wasm_drt.wasip2.cli.run.exports.Exports!FilteredImpl
  );
}
private enum componentTypeBytes = x"
0061736D0D0001000019167769742D636F6D706F6E656E742D656E636F64696E670400074E0141
02014102014203016A0000014000000004000372756E0101040013776173693A636C692F72756E
40302E322E31320500040017776173693A636C692F6578706F72747340302E322E313204000B0D
0100076578706F72747303000000440970726F647563657273010C70726F6365737365642D6279
020D7769742D636F6D706F6E656E7407302E3235392E300D7769742D62696E6467656E2D640630
2E36322E30
";

private enum componentTypeStr = (() {
  immutable input = componentTypeBytes;
  auto result = new char[input.length*3];

  foreach (i, b; input) {
    result[(i*3)+0] = '\\';

    ubyte n1 = (b >> 4) & 0xF;
    result[(i*3)+1] = n1 < 0xA ? cast(char)('0'+n1) : cast(char)('A'+(n1-0xA));

    ubyte n2 = b & 0xF;
    result[(i*3)+2] = n2 < 0xA ? cast(char)('0'+n2) : cast(char)('A'+(n2-0xA));
  }

  return cast(string)result;
})();

pragma(inline, false)
package(wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow {}


package(wasm_drt.wasip2) void __wit_bindgen_component_type() {
  imported!"ldc.llvmasm".__irEx!(
  "",
  "",
  `!wasm.custom_sections = !{!0}
  !0 = !{!"component-type:wit-bindgen:0.62.0:wasi:cli@0.2.12:exports:", !"`~componentTypeStr~`"}`,
  void
  );
}
