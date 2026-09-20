/++

+/
module wasm_drt.wasip2.io.streams.imports;


import wasm_drt.wasip2.wit;

public import wasm_drt.wasip2.io.streams.common;

static import wasm_drt.wasip2.io.error.imports;
static import wasm_drt.wasip2.io.poll.imports;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Error_ = wasm_drt.wasip2.io.error.imports.Error_;

/++

+/
alias Pollable = wasm_drt.wasip2.io.poll.imports.Pollable;

/++

+/
struct StreamError {
  mixin WitVariant!(
    Error_, // lastOperationFailed
    void, // closed
  );

public:
  enum Tag : ubyte {
    /++

    +/
    lastOperationFailed,

    /++

    +/
    closed,
  }
  pragma(inline, true) Tag tag() const @safe @nogc nothrow pure => _tag;

  /++

  +/
  alias lastOperationFailed = _create!(Tag.lastOperationFailed);
  /// ditto
  pragma(inline, true) bool isLastOperationFailed() const => _tag == Tag.lastOperationFailed;
  ///ditto
  alias getLastOperationFailed = _get!(Tag.lastOperationFailed);

  /++

  +/
  alias closed = _create!(Tag.closed);
  /// ditto
  pragma(inline, true) bool isClosed() const => _tag == Tag.closed;

  void witFree() @nogc nothrow {
  }

  void witDrop() @nogc nothrow {
    switch (_tag) with (Tag) {
      case lastOperationFailed: _get!(Tag.lastOperationFailed).witDrop; break;
      default: break;
    }
  }

  StreamError witClone() const @nogc nothrow {
    final switch (_tag) {
      case Tag.lastOperationFailed: return _create!(Tag.lastOperationFailed)(this._get!(Tag.lastOperationFailed).witClone); break;
      case Tag.closed: return _create!(Tag.closed); break;
    }
  }
}

/++

+/
struct InputStream {
  package(wasm_drt.wasip2) uint __handle = 0;

  pragma(inline, true)
  package(wasm_drt.wasip2) this(uint handle) @safe @nogc nothrow {
    __handle = handle;
  }

  
  pragma(inline, true) void witDrop() @trusted @nogc nothrow {
    if (!__handle) return; __import_drop(__handle); __handle = 0;
  }
  @wasmImport!("wasi:io/streams@0.2.12", "[resource-drop]input-stream")
  pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:resource_drop:input_stream")
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
    
    /++

    +/
    Result!(WitList!(ubyte), StreamError) read(ulong len) @trusted nothrow {
      align(size_t.sizeof) void[(3*size_t.sizeof)] _retArea = void;
      __import_read(this.__handle, len, _retArea.ptr);
      Result!(WitList!(ubyte), StreamError) _result10 = void;
      bool _isErr10 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr10) {
        StreamError _variant7 = void;
        auto _tag7 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + size_t.sizeof)));
        alias _Tag7 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag7) {
          case _Tag7.lastOperationFailed: {
            auto _handle5 = Error_(*(cast(uint*)(_retArea.ptr + (4+1*size_t.sizeof))));
            auto _payload8 = _handle5;
            _variant7 = StreamError.lastOperationFailed(_payload8);
            break;
          }
          case _Tag7.closed: {
            _variant7 = StreamError.closed();
            break;
          }
        }

        _result10 = Result!(WitList!(ubyte), StreamError).makeErr(_variant7);
      } else {
        auto _len1 = *(cast(size_t*)(_retArea.ptr + (2*size_t.sizeof)));
        auto _ptr1 = _len1 ? cast(ubyte*)(*(cast(void**)(_retArea.ptr + size_t.sizeof))) : null;
        auto _list2 = WitList!(ubyte)(_ptr1[0.._len1]);

        _result10 = Result!(WitList!(ubyte), StreamError).makeOk(_list2);
      }
      auto _flush11 = _result10;
      return _flush11;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]input-stream.read")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:input_stream.read")
    static private extern(C) void __import_read(uint, ulong, void*) nothrow;

    /++

    +/
    Result!(WitList!(ubyte), StreamError) blockingRead(ulong len) @trusted nothrow {
      align(size_t.sizeof) void[(3*size_t.sizeof)] _retArea = void;
      __import_blockingRead(this.__handle, len, _retArea.ptr);
      Result!(WitList!(ubyte), StreamError) _result10 = void;
      bool _isErr10 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr10) {
        StreamError _variant7 = void;
        auto _tag7 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + size_t.sizeof)));
        alias _Tag7 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag7) {
          case _Tag7.lastOperationFailed: {
            auto _handle5 = Error_(*(cast(uint*)(_retArea.ptr + (4+1*size_t.sizeof))));
            auto _payload8 = _handle5;
            _variant7 = StreamError.lastOperationFailed(_payload8);
            break;
          }
          case _Tag7.closed: {
            _variant7 = StreamError.closed();
            break;
          }
        }

        _result10 = Result!(WitList!(ubyte), StreamError).makeErr(_variant7);
      } else {
        auto _len1 = *(cast(size_t*)(_retArea.ptr + (2*size_t.sizeof)));
        auto _ptr1 = _len1 ? cast(ubyte*)(*(cast(void**)(_retArea.ptr + size_t.sizeof))) : null;
        auto _list2 = WitList!(ubyte)(_ptr1[0.._len1]);

        _result10 = Result!(WitList!(ubyte), StreamError).makeOk(_list2);
      }
      auto _flush11 = _result10;
      return _flush11;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]input-stream.blocking-read")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:input_stream.blocking_read")
    static private extern(C) void __import_blockingRead(uint, ulong, void*) nothrow;

    /++

    +/
    Result!(ulong, StreamError) skip(ulong len) @trusted nothrow {
      align(8) void[16] _retArea = void;
      __import_skip(this.__handle, len, _retArea.ptr);
      Result!(ulong, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 8)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 12)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(ulong, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(ulong, StreamError).makeOk(*(cast(ulong*)(_retArea.ptr + 8)));
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]input-stream.skip")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:input_stream.skip")
    static private extern(C) void __import_skip(uint, ulong, void*) nothrow;

    /++

    +/
    Result!(ulong, StreamError) blockingSkip(ulong len) @trusted nothrow {
      align(8) void[16] _retArea = void;
      __import_blockingSkip(this.__handle, len, _retArea.ptr);
      Result!(ulong, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 8)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 12)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(ulong, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(ulong, StreamError).makeOk(*(cast(ulong*)(_retArea.ptr + 8)));
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]input-stream.blocking-skip")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:input_stream.blocking_skip")
    static private extern(C) void __import_blockingSkip(uint, ulong, void*) nothrow;

    /++

    +/
    Pollable subscribe() @trusted nothrow {
      auto _ret = __import_subscribe(this.__handle);
      auto _handle0 = Pollable(_ret);
      return _handle0;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]input-stream.subscribe")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:input_stream.subscribe")
    static private extern(C) uint __import_subscribe(uint) nothrow;
  }
}

/++

+/
struct OutputStream {
  package(wasm_drt.wasip2) uint __handle = 0;

  pragma(inline, true)
  package(wasm_drt.wasip2) this(uint handle) @safe @nogc nothrow {
    __handle = handle;
  }

  
  pragma(inline, true) void witDrop() @trusted @nogc nothrow {
    if (!__handle) return; __import_drop(__handle); __handle = 0;
  }
  @wasmImport!("wasi:io/streams@0.2.12", "[resource-drop]output-stream")
  pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:resource_drop:output_stream")
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
    
    /++

    +/
    Result!(ulong, StreamError) checkWrite() @trusted nothrow {
      align(8) void[16] _retArea = void;
      __import_checkWrite(this.__handle, _retArea.ptr);
      Result!(ulong, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 8)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 12)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(ulong, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(ulong, StreamError).makeOk(*(cast(ulong*)(_retArea.ptr + 8)));
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]output-stream.check-write")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:output_stream.check_write")
    static private extern(C) void __import_checkWrite(uint, void*) nothrow;

    /++

    +/
    Result!(void, StreamError) write(in WitList!(ubyte) contents) @trusted nothrow {
      align(4) void[12] _retArea = void;
      __import_write(this.__handle, cast(void*)(contents.ptr), contents.length, _retArea.ptr);
      Result!(void, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 8)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(void, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(void, StreamError).makeOk();
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]output-stream.write")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:output_stream.write")
    static private extern(C) void __import_write(uint, void*, size_t, void*) nothrow;

    /++

    +/
    Result!(void, StreamError) blockingWriteAndFlush(in WitList!(ubyte) contents) @trusted nothrow {
      align(4) void[12] _retArea = void;
      __import_blockingWriteAndFlush(this.__handle, cast(void*)(contents.ptr), contents.length, _retArea.ptr);
      Result!(void, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 8)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(void, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(void, StreamError).makeOk();
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]output-stream.blocking-write-and-flush")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:output_stream.blocking_write_and_flush")
    static private extern(C) void __import_blockingWriteAndFlush(uint, void*, size_t, void*) nothrow;

    /++

    +/
    Result!(void, StreamError) flush() @trusted nothrow {
      align(4) void[12] _retArea = void;
      __import_flush(this.__handle, _retArea.ptr);
      Result!(void, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 8)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(void, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(void, StreamError).makeOk();
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]output-stream.flush")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:output_stream.flush")
    static private extern(C) void __import_flush(uint, void*) nothrow;

    /++

    +/
    Result!(void, StreamError) blockingFlush() @trusted nothrow {
      align(4) void[12] _retArea = void;
      __import_blockingFlush(this.__handle, _retArea.ptr);
      Result!(void, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 8)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(void, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(void, StreamError).makeOk();
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]output-stream.blocking-flush")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:output_stream.blocking_flush")
    static private extern(C) void __import_blockingFlush(uint, void*) nothrow;

    /++

    +/
    Pollable subscribe() @trusted nothrow {
      auto _ret = __import_subscribe(this.__handle);
      auto _handle0 = Pollable(_ret);
      return _handle0;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]output-stream.subscribe")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:output_stream.subscribe")
    static private extern(C) uint __import_subscribe(uint) nothrow;

    /++

    +/
    Result!(void, StreamError) writeZeroes(ulong len) @trusted nothrow {
      align(4) void[12] _retArea = void;
      __import_writeZeroes(this.__handle, len, _retArea.ptr);
      Result!(void, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 8)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(void, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(void, StreamError).makeOk();
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]output-stream.write-zeroes")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:output_stream.write_zeroes")
    static private extern(C) void __import_writeZeroes(uint, ulong, void*) nothrow;

    /++

    +/
    Result!(void, StreamError) blockingWriteZeroesAndFlush(ulong len) @trusted nothrow {
      align(4) void[12] _retArea = void;
      __import_blockingWriteZeroesAndFlush(this.__handle, len, _retArea.ptr);
      Result!(void, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 4)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 8)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(void, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(void, StreamError).makeOk();
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]output-stream.blocking-write-zeroes-and-flush")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:output_stream.blocking_write_zeroes_and_flush")
    static private extern(C) void __import_blockingWriteZeroesAndFlush(uint, ulong, void*) nothrow;

    /++

    +/
    Result!(ulong, StreamError) splice(InputStream.Borrow src, ulong len) @trusted nothrow {
      align(8) void[16] _retArea = void;
      __import_splice(this.__handle, src.__handle, len, _retArea.ptr);
      Result!(ulong, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 8)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 12)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(ulong, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(ulong, StreamError).makeOk(*(cast(ulong*)(_retArea.ptr + 8)));
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]output-stream.splice")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:output_stream.splice")
    static private extern(C) void __import_splice(uint, uint, ulong, void*) nothrow;

    /++

    +/
    Result!(ulong, StreamError) blockingSplice(InputStream.Borrow src, ulong len) @trusted nothrow {
      align(8) void[16] _retArea = void;
      __import_blockingSplice(this.__handle, src.__handle, len, _retArea.ptr);
      Result!(ulong, StreamError) _result8 = void;
      bool _isErr8 = (cast(uint)(*(cast(ubyte*)(_retArea.ptr + 0)))) != 0;
      if (_isErr8) {
        StreamError _variant5 = void;
        auto _tag5 = cast(uint)(*(cast(ubyte*)(_retArea.ptr + 8)));
        alias _Tag5 = StreamError.Tag;
        final switch (cast(StreamError.Tag)_tag5) {
          case _Tag5.lastOperationFailed: {
            auto _handle3 = Error_(*(cast(uint*)(_retArea.ptr + 12)));
            auto _payload6 = _handle3;
            _variant5 = StreamError.lastOperationFailed(_payload6);
            break;
          }
          case _Tag5.closed: {
            _variant5 = StreamError.closed();
            break;
          }
        }

        _result8 = Result!(ulong, StreamError).makeErr(_variant5);
      } else {
        
        _result8 = Result!(ulong, StreamError).makeOk(*(cast(ulong*)(_retArea.ptr + 8)));
      }
      auto _flush9 = _result8;
      return _flush9;
    }
    /// ditto
    @wasmImport!("wasi:io/streams@0.2.12", "[method]output-stream.blocking-splice")
    pragma(mangle, "__wit_import_wasi:io__streams@0.2.12__:method:output_stream.blocking_splice")
    static private extern(C) void __import_blockingSplice(uint, uint, ulong, void*) nothrow;
  }
}
