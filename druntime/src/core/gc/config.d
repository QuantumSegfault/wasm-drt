/**
* Contains the garbage collector configuration.
*
* Copyright: Copyright Digital Mars 2016
* License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/

module core.gc.config;

import core.internal.parseoptions;
import core.internal.printing;
import core.stdc.stdio : stdout;

__gshared Config config;

private __gshared bool _initialized;

struct Config
{
    bool disable;            // start disabled
    bool fork = false;       // optional concurrent behaviour
    ubyte profile;           // enable profiling with summary when terminating program

    @MemVal size_t initReserve;      // initial reserve (bytes)
    @MemVal size_t minPoolSize = 1  << 20;  // initial and minimum pool size (bytes)
    @MemVal size_t maxPoolSize = 64 << 20;  // maximum pool size (bytes)
    @MemVal size_t incPoolSize = 3  << 20;  // pool size increment (bytes)

    // Limit under which the GC will try to keep its heap (bytes)
    // The GC does this on a best effort basis, and exceeding this size
    // might lead to a performance cliff.
    @MemVal size_t heapSizeLimit = size_t.max;

    uint parallel = 99;      // number of additional threads for marking (limited by cpuid.threadsPerCPU-1)
    float heapSizeFactor = 2.0; // heap size to used memory ratio
    string cleanup = "collect"; // select gc cleanup method none|collect|finalize

@nogc nothrow:

    bool initialize()
    {
        if (!_initialized)
            _initialized = initConfigOptions(this, "gcopt");
        return _initialized;
    }

    void help() @nogc nothrow
    {
        stdout.writeLine("GC options are specified as white space separated assignments:");
        
        stdout.writeStr("    disable:0|1    - start disabled (");
        stdout.writeSigned(disable);
        stdout.writeLine(")");
        
        stdout.writeStr("    fork:0|1       - set fork behaviour (");
        stdout.writeSigned(fork);
        stdout.writeLine(")");
        
        stdout.writeStr("    profile:0|1|2  - enable profiling with summary when terminating program (");
        stdout.writeSigned(profile);
        stdout.writeLine(")");
        
        auto _initReserve = initReserve.bytes2prettyStruct;
        auto _minPoolSize = minPoolSize.bytes2prettyStruct;
        auto _maxPoolSize = maxPoolSize.bytes2prettyStruct;
        auto _incPoolSize = incPoolSize.bytes2prettyStruct;
        
        stdout.writeLine(" - select gc implementation (default = conservative)\n");
        
        stdout.writeStr("    initReserve:N  - initial memory to reserve in MB (");
        stdout.writeSigned(_initReserve.v);
        stdout.writeChar(_initReserve.u);
        stdout.writeLine(")");
        
        stdout.writeStr("    minPoolSize:N  - initial and minimum pool size in MB (");
        stdout.writeSigned(_minPoolSize.v);
        stdout.writeChar(_minPoolSize.u);
        stdout.writeLine(")");
        
        stdout.writeStr("    maxPoolSize:N  - maximum pool size in MB (");
        stdout.writeSigned(_maxPoolSize.v);
        stdout.writeChar(_maxPoolSize.u);
        stdout.writeLine(")");
        
        stdout.writeStr("    incPoolSize:N  - pool size increment MB (");
        stdout.writeSigned(_incPoolSize.v);
        stdout.writeChar(_incPoolSize.u);
        stdout.writeLine(")");
        
        stdout.writeStr("    parallel:N     - number of additional threads for marking (");
        stdout.writeSigned(cast(long)parallel);
        stdout.writeLine(")");
        
        stdout.writeStr("    heapSizeFactor:N - targeted heap size to used memory ratio (");
        // TODO: detach from libc with custom float parser
        imported!"core.stdc.stdio".printf("%g", heapSizeFactor);
        stdout.writeLine(")");
        
        stdout.writeLine("    cleanup:none|collect|finalize - how to treat live objects when terminating (collect)\n");
        stdout.writeLine("    Memory-related values can use B, K, M or G suffixes.");
    }

    string errorName() @nogc nothrow { return "GC"; }
}

private struct PrettyBytes
{
    long v;
    char u; /// unit
}

pure @nogc nothrow:

private PrettyBytes bytes2prettyStruct(size_t val)
{
    char c = prettyBytes(val);

    return PrettyBytes(val, c);
}

private static char prettyBytes(ref size_t val)
{
    char sym = 'B';

    if (val == 0)
        return sym;

    char[3] units = ['K', 'M', 'G'];

    foreach (u; units)
        if (val % (1 << 10) == 0)
        {
            val /= (1 << 10);
            sym = u;
        }
        else if (sym != 'B')
            break;

    return sym;
}
unittest
{
    size_t v = 1024;
    assert(prettyBytes(v) == 'K');
    assert(v == 1);

    v = 1025;
    assert(prettyBytes(v) == 'B');
    assert(v == 1025);

    v = 1024UL * 1024 * 1024 * 3;
    assert(prettyBytes(v) == 'G');
    assert(v == 3);

    v = 1024 * 1024 + 1;
    assert(prettyBytes(v) == 'B');
    assert(v == 1024 * 1024 + 1);
}
