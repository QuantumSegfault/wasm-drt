/++

+/
module wasm_drt.wasip2.filesystem.types.common;


import wasm_drt.wasip2.wit;

static import wasm_drt.wasip2.io.streams.common;
static import wasm_drt.wasip2.clocks.wall_clock.common;

package (wasm_drt.wasip2) void __wit_bindgen_component_type_force_link() pure @nogc nothrow => imported!"wasm_drt.wasip2.cli.imports".__wit_bindgen_component_type_force_link();

/++

+/
alias Datetime = wasm_drt.wasip2.clocks.wall_clock.common.Datetime;

/++

+/
alias Filesize = ulong;

/++

+/
enum DescriptorType : ubyte {
  /++

  +/
  unknown,

  /++

  +/
  blockDevice,

  /++

  +/
  characterDevice,

  /++

  +/
  directory,

  /++

  +/
  fifo,

  /++

  +/
  symbolicLink,

  /++

  +/
  regularFile,

  /++

  +/
  socket,
}
/++

+/
struct DescriptorFlags {
  mixin WitFlags!ubyte;

  /++

  +/
  enum read = DescriptorFlags[0];

  /++

  +/
  enum write = DescriptorFlags[1];

  /++

  +/
  enum fileIntegritySync = DescriptorFlags[2];

  /++

  +/
  enum dataIntegritySync = DescriptorFlags[3];

  /++

  +/
  enum requestedWriteSync = DescriptorFlags[4];

  /++

  +/
  enum mutateDirectory = DescriptorFlags[5];
}

/++

+/
struct PathFlags {
  mixin WitFlags!ubyte;

  /++

  +/
  enum symlinkFollow = PathFlags[0];
}

/++

+/
struct OpenFlags {
  mixin WitFlags!ubyte;

  /++

  +/
  enum create = OpenFlags[0];

  /++

  +/
  enum directory = OpenFlags[1];

  /++

  +/
  enum exclusive = OpenFlags[2];

  /++

  +/
  enum truncate = OpenFlags[3];
}

/++

+/
alias LinkCount = ulong;

/++

+/
struct DescriptorStat {
  /++

  +/
  DescriptorType type;

  /++

  +/
  LinkCount linkCount;

  /++

  +/
  Filesize size;

  /++

  +/
  Option!(Datetime) dataAccessTimestamp;

  /++

  +/
  Option!(Datetime) dataModificationTimestamp;

  /++

  +/
  Option!(Datetime) statusChangeTimestamp;

  void witFree() @nogc nothrow {
  }

  void witDrop() @nogc nothrow {
  }

  DescriptorStat witClone() const @nogc nothrow {
    DescriptorStat clone = void;
    clone.type = this.type.witClone;
    clone.linkCount = this.linkCount.witClone;
    clone.size = this.size.witClone;
    clone.dataAccessTimestamp = this.dataAccessTimestamp.witClone;
    clone.dataModificationTimestamp = this.dataModificationTimestamp.witClone;
    clone.statusChangeTimestamp = this.statusChangeTimestamp.witClone;
    return clone;
  }
}

/++

+/
struct NewTimestamp {
  mixin WitVariant!(
    void, // noChange
    void, // now
    Datetime, // timestamp
  );

public:
  enum Tag : ubyte {
    /++

    +/
    noChange,

    /++

    +/
    now,

    /++

    +/
    timestamp,
  }
  pragma(inline, true) Tag tag() const @safe @nogc nothrow pure => _tag;

  /++

  +/
  alias noChange = _create!(Tag.noChange);
  /// ditto
  pragma(inline, true) bool isNoChange() const => _tag == Tag.noChange;

  /++

  +/
  alias now = _create!(Tag.now);
  /// ditto
  pragma(inline, true) bool isNow() const => _tag == Tag.now;

  /++

  +/
  alias timestamp = _create!(Tag.timestamp);
  /// ditto
  pragma(inline, true) bool isTimestamp() const => _tag == Tag.timestamp;
  ///ditto
  alias getTimestamp = _get!(Tag.timestamp);

  void witFree() @nogc nothrow {
  }

  void witDrop() @nogc nothrow {
  }

  NewTimestamp witClone() const @nogc nothrow {
    final switch (_tag) {
      case Tag.noChange: return _create!(Tag.noChange); break;
      case Tag.now: return _create!(Tag.now); break;
      case Tag.timestamp: return _create!(Tag.timestamp)(this._get!(Tag.timestamp).witClone); break;
    }
  }
}

/++

+/
struct DirectoryEntry {
  /++

  +/
  DescriptorType type;

  /++

  +/
  WitString name;

  void witFree() @nogc nothrow {
    name.witFree;
  }

  void witDrop() @nogc nothrow {
  }

  DirectoryEntry witClone() const @nogc nothrow {
    DirectoryEntry clone = void;
    clone.type = this.type.witClone;
    clone.name = this.name.witClone;
    return clone;
  }
}

/++

+/
enum ErrorCode : ubyte {
  /++

  +/
  access,

  /++

  +/
  wouldBlock,

  /++

  +/
  already,

  /++

  +/
  badDescriptor,

  /++

  +/
  busy,

  /++

  +/
  deadlock,

  /++

  +/
  quota,

  /++

  +/
  exist,

  /++

  +/
  fileTooLarge,

  /++

  +/
  illegalByteSequence,

  /++

  +/
  inProgress,

  /++

  +/
  interrupted,

  /++

  +/
  invalid,

  /++

  +/
  io,

  /++

  +/
  isDirectory,

  /++

  +/
  loop,

  /++

  +/
  tooManyLinks,

  /++

  +/
  messageSize,

  /++

  +/
  nameTooLong,

  /++

  +/
  noDevice,

  /++

  +/
  noEntry,

  /++

  +/
  noLock,

  /++

  +/
  insufficientMemory,

  /++

  +/
  insufficientSpace,

  /++

  +/
  notDirectory,

  /++

  +/
  notEmpty,

  /++

  +/
  notRecoverable,

  /++

  +/
  unsupported,

  /++

  +/
  noTty,

  /++

  +/
  noSuchDevice,

  /++

  +/
  overflow,

  /++

  +/
  notPermitted,

  /++

  +/
  pipe,

  /++

  +/
  readOnly,

  /++

  +/
  invalidSeek,

  /++

  +/
  textFileBusy,

  /++

  +/
  crossDevice,
}
/++

+/
enum Advice : ubyte {
  /++

  +/
  normal,

  /++

  +/
  sequential,

  /++

  +/
  random,

  /++

  +/
  willNeed,

  /++

  +/
  dontNeed,

  /++

  +/
  noReuse,
}
/++

+/
struct MetadataHashValue {
  /++

  +/
  ulong lower;

  /++

  +/
  ulong upper;

  void witFree() @nogc nothrow {
  }

  void witDrop() @nogc nothrow {
  }

  MetadataHashValue witClone() const @nogc nothrow {
    MetadataHashValue clone = void;
    clone.lower = this.lower.witClone;
    clone.upper = this.upper.witClone;
    return clone;
  }
}
