/**
 * This module contains a minimal garbage collector implementation according to
 * published requirements.  This library is mostly intended to serve as an
 * example, but it is usable in applications which do not rely on a garbage
 * collector to clean up memory (ie. when dynamic array resizing is not used,
 * and all memory allocated with 'new' is freed deterministically with
 * 'delete').
 *
 * Please note that block attribute data must be tracked, or at a minimum, the
 * FINALIZE bit must be tracked for any allocated memory block because calling
 * rt_finalize on a non-object block can result in an access violation.  In the
 * allocator below, this tracking is done via a leading uint bitmask.  A real
 * allocator may do better to store this data separately, similar to the basic
 * GC.
 *
 * Copyright: Copyright Sean Kelly 2005 - 2016.
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Sean Kelly
 */
module core.internal.gc.impl.manual.gc;

import core.gc.gcinterface;

import core.internal.container.array;

import core.thread.threadbase : ThreadBase;

import cstdlib = core.stdc.stdlib : calloc, free, malloc, realloc;
static import core.memory;

extern (C) noreturn onOutOfMemoryError(void* pretend_sideffect = null,
        string file = __FILE__, size_t line = __LINE__) @trusted pure nothrow @nogc; /* dmd @@@BUG11461@@@ */

__gshared Array!Root roots;
__gshared Array!Range ranges;

extern (C) nothrow @nogc:

bool gc_impl_init()
{
    return true;
}

void* gc_impl_malloc(size_t size, uint bits, const TypeInfo ti)
{
    void* p = cstdlib.malloc(size);

    if (size && p is null)
        onOutOfMemoryError();
    return p;
}

BlkInfo gc_impl_qalloc(size_t size, uint bits, const scope TypeInfo ti)
{
    BlkInfo retval;
    retval.base = gc_impl_malloc(size, bits, ti);
    retval.size = size;
    retval.attr = bits;
    return retval;
}

void* gc_impl_calloc(size_t size, uint bits, const TypeInfo ti)
{
    void* p = cstdlib.calloc(1, size);

    if (size && p is null)
        onOutOfMemoryError();
    return p;
}

void* gc_impl_realloc(void* p, size_t size, uint bits, const TypeInfo ti)
{
    p = cstdlib.realloc(p, size);

    if (size && p is null)
        onOutOfMemoryError();
    return p;
}

void gc_impl_free(void* p)
{
    cstdlib.free(p);
}

void gc_impl_addRoot(void* p)
{
    roots.insertBack(Root(p));
}

void gc_impl_removeRoot(void* p)
{
    foreach (ref r; roots)
    {
        if (r is p)
        {
            r = roots.back;
            roots.popBack();
            return;
        }
    }
    assert(false);
}

void gc_impl_addRange(void* p, size_t sz, const TypeInfo ti = null)
{
    ranges.insertBack(Range(p, p + sz, cast() ti));
}

void gc_impl_removeRange(void* p)
{
    foreach (ref r; ranges)
    {
        if (r.pbot is p)
        {
            r = ranges.back;
            ranges.popBack();
            return;
        }
    }
    assert(false);
}
