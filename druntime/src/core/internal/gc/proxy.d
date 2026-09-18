/**
 * Contains the external GC interface.
 *
 * Copyright: D Language Foundation 2005 - 2021.
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Walter Bright, Sean Kelly
 */
module core.internal.gc.proxy;

import core.gc.config;
import core.gc.gcinterface;
import core.attribute : weak;
import core.internal.container.array;
import core.thread.threadbase : ThreadBase;
import core.internal.abort : abort;

static import core.memory;

private
{
    alias BlkInfo = core.memory.GC.BlkInfo;

    import core.internal.spinlock;
    static SpinLock instanceLock;

    __gshared bool isInstanceInit = false;

    __gshared Array!Root preinitRoots;
    __gshared Array!Range preinitRanges;

    extern (C)
    {
        bool gc_impl_init() nothrow @nogc;
        void gc_impl_term() nothrow @nogc;
        void gc_impl_enable();
        void gc_impl_disable();
        void gc_impl_collect() nothrow;
        void gc_impl_minimize() nothrow;
        uint gc_impl_getAttr(void* p) nothrow;
        uint gc_impl_setAttr(void* p, uint mask) nothrow;
        uint gc_impl_clrAttr(void* p, uint mask) nothrow;
        void* gc_impl_malloc(size_t size, uint bits, const TypeInfo ti) nothrow;
        BlkInfo gc_impl_qalloc(size_t size, uint bits, const scope TypeInfo ti) nothrow;
        void* gc_impl_calloc(size_t size, uint bits, const TypeInfo ti) nothrow;
        void* gc_impl_realloc(void* p, size_t size, uint bits, const TypeInfo ti) nothrow;
        size_t gc_impl_extend(void* p, size_t minsize, size_t maxsize, const TypeInfo ti) nothrow;
        size_t gc_impl_reserve(size_t size) nothrow;
        void gc_impl_free(void* p) nothrow @nogc;
        void* gc_impl_addrOf(void* p) nothrow @nogc;
        size_t gc_impl_sizeOf(void* p) nothrow @nogc;
        BlkInfo gc_impl_query(void* p) nothrow;
        core.memory.GC.Stats gc_impl_stats() @safe nothrow @nogc;
        core.memory.GC.ProfileStats gc_impl_profileStats() @safe nothrow @nogc;
        void gc_impl_addRoot(void* p) nothrow @nogc;
        void gc_impl_removeRoot(void* p) nothrow @nogc;
        void gc_impl_addRange(void* p, size_t sz, const TypeInfo ti) nothrow @nogc;
        void gc_impl_removeRange(void* p) nothrow @nogc;
        void gc_impl_runFinalizers(const scope void[] segment) nothrow;
        bool gc_impl_inFinalizer() nothrow @nogc @safe;
        ulong gc_impl_allocatedInCurrentThread() nothrow;
        void[] gc_impl_getArrayUsed(void* ptr, bool atomic) nothrow;
        bool gc_impl_expandArrayUsed(void[] slice, size_t newUsed, bool atomic) nothrow @safe;
        size_t gc_impl_reserveArrayCapacity(void[] slice, size_t request, bool atomic) nothrow @safe;
        bool gc_impl_shrinkArrayUsed(void[] slice, size_t existingUsed, bool atomic) nothrow;
        void gc_impl_initThread(ThreadBase thread) nothrow @nogc;
        void gc_impl_cleanupThread(ThreadBase thread) nothrow @nogc;
    }
}

extern (C)
{
    void gc_init() nothrow
    {
        instanceLock.lock();
        if (!isInstanceInit)
        {
            config.initialize();

            if (!gc_impl_init()) abort("Cannot initialize the garbage collector.\n"); 

            foreach (ref r; preinitRanges)
                gc_impl_addRange(r.pbot, r.ptop - r.pbot, r.ti);

            foreach (ref r; preinitRoots)
                gc_impl_addRoot(r.proot);

            preinitRanges.reset();
            preinitRoots.reset();

            isInstanceInit = true;
        }
        instanceLock.unlock();
    }

    void gc_term()
    {
        if (isInstanceInit)
        {
            switch (config.cleanup)
            {
                default:
                    import core.stdc.stdio : fprintf, stderr;
                    import core.atomic : atomicLoad;

                    fprintf(atomicLoad(stderr), "Unknown GC cleanup method, please recheck ('%.*s').\n",
                            cast(int)config.cleanup.length, config.cleanup.ptr);
                    break;
                case "none":
                    break;
                case "collect":
                    gc_impl_collect();
                    break;
                case "finalize":
                    gc_impl_runFinalizers((cast(ubyte*)null)[0 .. size_t.max]);
                    break;
            }
        }
    }

    void gc_enable()
    {
        if (!isInstanceInit) gc_init();
        gc_impl_enable();
    }

    void gc_disable()
    {
        if (!isInstanceInit) gc_init();
        gc_impl_disable();
    }

    void gc_collect() nothrow
    {
        if (!isInstanceInit) return;
        gc_impl_collect();
    }

    void gc_minimize() nothrow
    {
        if (!isInstanceInit) return;
        gc_impl_minimize();
    }

    uint gc_getAttr( void* p ) nothrow
    {
        if (!isInstanceInit) return 0;
        return gc_impl_getAttr(p);
    }

    uint gc_setAttr( void* p, uint a ) nothrow
    {
        if (!isInstanceInit) return 0;
        return gc_impl_setAttr(p, a);
    }

    uint gc_clrAttr( void* p, uint a ) nothrow
    {
        if (!isInstanceInit) return 0;
        return gc_impl_clrAttr(p, a);
    }

    void* gc_malloc( size_t sz, uint ba = 0, const scope TypeInfo ti = null ) nothrow
    {
        if (!isInstanceInit) gc_init();
        return gc_impl_malloc(sz, ba, ti);
    }

    BlkInfo gc_qalloc(size_t sz, uint ba = 0, const scope TypeInfo ti = null) nothrow
    {
        if (!isInstanceInit) gc_init();
        return gc_impl_qalloc(sz, ba, ti);
    }

    void* gc_calloc(size_t sz, uint ba = 0, const scope TypeInfo ti = null) nothrow
    {
        if (!isInstanceInit) gc_init();
        return gc_impl_calloc(sz, ba, ti);
    }

    void* gc_realloc(void* p, size_t sz, uint ba = 0, const scope TypeInfo ti = null) nothrow
    {
        if (!isInstanceInit) gc_init();
        return gc_impl_realloc(p, sz, ba, ti);
    }

    size_t gc_extend(void* p, size_t mx, size_t sz, const scope TypeInfo ti = null) nothrow
    {
        if (!isInstanceInit) return 0;
        return gc_impl_extend(p, mx, sz, ti);
    }

    size_t gc_reserve(size_t sz) nothrow
    {
        if (!isInstanceInit) gc_init();
        return gc_impl_reserve(sz);
    }

    void gc_free( void* p ) nothrow @nogc
    {
        if (!isInstanceInit) {
            if (p) assert(false, "Invalid memory deallocation");
            return;
        }
        gc_impl_free(p);
    }

    void* gc_addrOf( void* p ) nothrow @nogc
    {
        if (!isInstanceInit) return null;
        return gc_impl_addrOf(p);
    }

    size_t gc_sizeOf( void* p ) nothrow @nogc
    {
        if (!isInstanceInit) return 0;
        return gc_impl_sizeOf(p);
    }

    BlkInfo gc_query( void* p ) nothrow
    {
        if (!isInstanceInit) return BlkInfo.init;
        return gc_impl_query(p);
    }

    core.memory.GC.Stats gc_stats() @trusted nothrow @nogc
    {
        if (!isInstanceInit) return typeof(return).init;
        return gc_impl_stats();
    }

    core.memory.GC.ProfileStats gc_profileStats() @trusted nothrow @nogc
    {
        if (!isInstanceInit) return typeof(return).init;
        return gc_impl_profileStats();
    }

    void gc_addRoot( void* p ) nothrow @nogc
    {
        if (!isInstanceInit) {
            preinitRoots.insertBack(Root(p));
            return;
        }
        gc_impl_addRoot(p);
    }

    void gc_addRange( void* p, size_t sz, const TypeInfo ti = null ) nothrow @nogc
    {
        if (!isInstanceInit) {
            preinitRanges.insertBack(Range(p, p + sz, cast() ti));
            return;
        }
        gc_impl_addRange(p, sz, ti);
    }

    void gc_removeRoot( void* p ) nothrow
    {
        if (!isInstanceInit)
        {
            foreach (ref r; preinitRoots)
            {
                if (r is p)
                {
                    r = preinitRoots.back;
                    preinitRoots.popBack();
                    return;
                }
            }
            return;
        }
        gc_impl_removeRoot(p);
    }

    void gc_removeRange( void* p ) nothrow
    {
        if (!isInstanceInit)
        {
            foreach (ref r; preinitRanges)
            {
                if (r.pbot is p)
                {
                    r = preinitRanges.back;
                    preinitRanges.popBack();
                    return;
                }
            }
            return;
        }
        gc_impl_removeRange(p);
    }

    void gc_runFinalizers(const scope void[] segment ) nothrow
    {
        if (!isInstanceInit) return;
        gc_impl_runFinalizers(segment);
    }

    bool gc_inFinalizer() nothrow @nogc @trusted
    {
        if (!isInstanceInit) return false;
        return gc_impl_inFinalizer();
    }

    ulong gc_allocatedInCurrentThread() nothrow
    {
        if (!isInstanceInit) return 0;
        return gc_impl_allocatedInCurrentThread();
    }

    void[] gc_getArrayUsed(void *ptr, bool atomic) nothrow
    {
        if (!isInstanceInit) return null;
        return gc_impl_getArrayUsed(ptr, atomic);
    }

    bool gc_expandArrayUsed(void[] slice, size_t newUsed, bool atomic) nothrow
    {
        if (!isInstanceInit) return false;
        return gc_impl_expandArrayUsed(slice, newUsed, atomic);
    }

    size_t gc_reserveArrayCapacity(void[] slice, size_t request, bool atomic) nothrow
    {
        if (!isInstanceInit) return 0;
        return gc_impl_reserveArrayCapacity(slice, request, atomic);
    }

    bool gc_shrinkArrayUsed(void[] slice, size_t existingUsed, bool atomic) nothrow
    {
        if (!isInstanceInit) return 0;
        return gc_impl_shrinkArrayUsed(slice, existingUsed, atomic);
    }

    void gc_initThread(ThreadBase thread) nothrow @nogc
    {
        if (!isInstanceInit) return;
        gc_impl_initThread(thread);
    }

    void gc_cleanupThread(ThreadBase thread) nothrow @nogc
    {
        if (!isInstanceInit) return;
        gc_impl_cleanupThread(thread);
    }
}
