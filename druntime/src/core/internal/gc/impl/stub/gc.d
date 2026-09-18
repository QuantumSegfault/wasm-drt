module core.internal.gc.impl.stub.gc;

import core.thread.threadbase : ThreadBase;
static import core.memory;

alias BlkInfo = core.memory.GC.BlkInfo;

extern (C) @nogc nothrow:

bool gc_impl_init()
{
    import core.stdc.stdio : fprintf, stderr;
    import core.stdc.stdlib : exit;
    import core.atomic : atomicLoad;

    fprintf(atomicLoad(stderr), "No GC was initialized. Please link a GC implementation in.\n");
    return false;
}

void gc_impl_enable()
{
}

void gc_impl_disable()
{
}

void gc_impl_collect()
{
}

void gc_impl_minimize()
{
}

uint gc_impl_getAttr(void*) => 0;
uint gc_impl_setAttr(void*, uint) => 0;
uint gc_impl_clrAttr(void*, uint) => 0;
void* gc_impl_malloc(size_t, uint, const TypeInfo) => null;
BlkInfo gc_impl_qalloc(size_t sz, uint ba, const scope TypeInfo ti) => BlkInfo.init;
void* gc_impl_calloc(size_t sz, uint ba, const scope TypeInfo ti) => null;
void* gc_impl_realloc(void* p, size_t sz, uint ba, const scope TypeInfo ti) => null;
size_t gc_impl_extend(void*, size_t, size_t, const TypeInfo) => 0;
size_t gc_impl_reserve(size_t) => 0;

void gc_impl_free(void*)
{
}

void* gc_impl_addrOf(void*) => null;
size_t gc_impl_sizeOf(void*) => 0;
BlkInfo gc_impl_query(void*) => BlkInfo.init;
core.memory.GC.Stats gc_impl_stats() @safe => typeof(return).init;
core.memory.GC.ProfileStats gc_impl_profileStats() @safe => typeof(return).init;

void gc_impl_addRoot(void*)
{
}

void gc_impl_removeRoot(void*)
{
}

void gc_impl_addRange(void*, size_t, const TypeInfo)
{
}

void gc_impl_removeRange(void*)
{
}

void gc_impl_runFinalizers(const scope void[])
{
}

bool gc_impl_inFinalizer() @safe => false;
ulong gc_impl_allocatedInCurrentThread() => 0;
void[] gc_impl_getArrayUsed(void*, bool) => null;
bool gc_impl_expandArrayUsed(void[], size_t, bool) @safe => false;
size_t gc_impl_reserveArrayCapacity(void[], size_t, bool) @safe => 0;
bool gc_impl_shrinkArrayUsed(void[], size_t, bool) => false;

void gc_impl_initThread(ThreadBase)
{
}

void gc_impl_cleanupThread(ThreadBase)
{
}
