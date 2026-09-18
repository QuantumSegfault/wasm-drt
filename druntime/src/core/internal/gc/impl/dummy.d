module core.internal.gc.impl.dummy;

import core.thread.threadbase : ThreadBase;
static import core.memory;
import core.attribute : weak;

private:

alias BlkInfo = core.memory.GC.BlkInfo;

extern (C) @nogc nothrow:

bool gc_impl_init() @weak
{
    import core.stdc.stdio : fprintf, stderr;
    import core.stdc.stdlib : exit;
    import core.atomic : atomicLoad;

    fprintf(atomicLoad(stderr), "No GC was initialized. Please link a GC implementation in.\n");
    return false;
}

void gc_impl_enable() @weak
{
}

void gc_impl_disable() @weak
{
}

void gc_impl_collect() @weak
{
}

void gc_impl_minimize() @weak
{
}

uint gc_impl_getAttr(void*) @weak => 0;
uint gc_impl_setAttr(void*, uint) @weak => 0;
uint gc_impl_clrAttr(void*, uint) @weak => 0;
void* gc_impl_malloc(size_t, uint, const TypeInfo) @weak => null;
BlkInfo gc_impl_qalloc(size_t sz, uint ba, const scope TypeInfo ti) @weak => BlkInfo.init;
void* gc_impl_calloc(size_t sz, uint ba, const scope TypeInfo ti) @weak => null;
void* gc_impl_realloc(void* p, size_t sz, uint ba, const scope TypeInfo ti) @weak => null;
size_t gc_impl_extend(void*, size_t, size_t, const TypeInfo) @weak => 0;
size_t gc_impl_reserve(size_t) @weak => 0;

void gc_impl_free(void*) @weak
{
}

void* gc_impl_addrOf(void*) @weak => null;
size_t gc_impl_sizeOf(void*) @weak => 0;
BlkInfo gc_impl_query(void*) @weak => BlkInfo.init;
core.memory.GC.Stats gc_impl_stats() @safe @weak => typeof(return).init;
core.memory.GC.ProfileStats gc_impl_profileStats() @safe @weak => typeof(return).init;

void gc_impl_addRoot(void*) @weak
{
}

void gc_impl_removeRoot(void*) @weak
{
}

void gc_impl_addRange(void*, size_t, const TypeInfo) @weak
{
}

void gc_impl_removeRange(void*) @weak
{
}

void gc_impl_runFinalizers(const scope void[]) @weak
{
}

bool gc_impl_inFinalizer() @safe @weak => false;
ulong gc_impl_allocatedInCurrentThread() @weak => 0;
void[] gc_impl_getArrayUsed(void*, bool) @weak => null;
bool gc_impl_expandArrayUsed(void[], size_t, bool) @safe @weak => false;
size_t gc_impl_reserveArrayCapacity(void[], size_t, bool) @safe @weak => 0;
bool gc_impl_shrinkArrayUsed(void[], size_t, bool) @weak => false;

void gc_impl_initThread(ThreadBase) @weak
{
}

void gc_impl_cleanupThread(ThreadBase) @weak
{
}
