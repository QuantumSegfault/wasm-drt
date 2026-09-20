/++

+/
module wasm_drt.wasip2.cli.run.exports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.cli.run.common;


package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.exports".__wit_bindgen_component_type_force_link();

package(wasm_drt.wasip2) template Exports(Impl...) {

  /++
  Run the program.
  +/
  alias run_Sig = Result!(void, void) function();
  /// ditto
  alias run_Impl = findWitExportFunc!("wasi:cli/run@0.2.12", "run", run_Sig, Impl);
  /// ditto
  @wasmExport!("wasi:cli/run@0.2.12#run")
  pragma(mangle, "_start")
  private extern(C) uint __export_run() {
    auto _ret = run_Impl();
    uint _resultPart4;
    if (_ret.isErr) {
      
      _resultPart4 = 1;
    } else {
      
      _resultPart4 = 0;
    }
    return _resultPart4;
  }
}

