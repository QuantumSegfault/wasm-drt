/**
 * Exception handling support for Dwarf-style portable exceptions.
 *
 * Copyright: Copyright (c) 2015-2016 by D Language Foundation
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors: Walter Bright
 * Source: $(DRUNTIMESRC rt/_dwarfeh.d)
 */

module rt.dwarfeh;

//debug = EH_personality;

import core.internal.backtrace.unwind;
import core.stdc.stdio : fprintf, printf, stderr;
import core.stdc.stdlib : abort, calloc, free;
import rt.dmain2 : _d_print_throwable;

extern (C)
{
    int _d_isbaseof(ClassInfo b, ClassInfo c);
    void _d_createTrace(Throwable o, void* context);
}

private _Unwind_Ptr readUnaligned(T, bool consume)(ref const(ubyte)* p)
{
    import core.stdc.string : memcpy;
    T value = void;
    memcpy(&value, p, T.sizeof);

    static if (consume)
        p += T.sizeof;
    return cast(_Unwind_Ptr) value;
}

debug (EH_personality)
{
    private void writeln(in char* format, ...) @nogc nothrow
    {
        import core.stdc.stdarg : va_list, va_start;
        import core.stdc.stdio : fflush, stdout, vfprintf;

        va_list args;
        va_start(args, format);
        vfprintf(stdout, format, args);
        fprintf(stdout, "\n");
        fflush(stdout);
    }
}

/* High 4 bytes = vendor, low 4 bytes = language
 * For us: "DMD\0D\0\0\0"
 */
enum _Unwind_Exception_Class dmdExceptionClass =
        (cast(_Unwind_Exception_Class)'D' << 56) |
        (cast(_Unwind_Exception_Class)'M' << 48) |
        (cast(_Unwind_Exception_Class)'D' << 40) |
        (cast(_Unwind_Exception_Class)'D' << 24);

/**
 * Wrap the unwinder's data with our own compiler specific struct
 * with our own data.
 */
struct ExceptionHeader
{
    Throwable object;                   // the thrown D object
    _Unwind_Exception exception_object; // the unwinder's data

    // Save info on the handler that was detected
    int handler;                        // which catch
    const(ubyte)* languageSpecificData; // Language Specific Data Area for function enclosing the handler
    _Unwind_Ptr landingPad;             // pointer to catch code

    // Stack other thrown exceptions in current thread through here.
    ExceptionHeader* next;

    static ExceptionHeader* stack;      // thread local stack of chained exceptions

    /* Pre-allocate storage for 1 instance per thread.
     * Use calloc/free for multiple exceptions in flight.
     * Does not use GC
     */
    static ExceptionHeader ehstorage;

    /************
     * Allocate and initialize an ExceptionHeader.
     * Params:
     *  o = thrown object
     * Returns:
     *  allocated and initalized ExceptionHeader
     */
    static ExceptionHeader* create(Throwable o) @nogc
    {
        auto eh = &ehstorage;
        if (eh.object)                  // if in use
        {
            eh = cast(ExceptionHeader*).calloc(1, ExceptionHeader.sizeof);
            if (!eh)
                terminate(__LINE__);              // out of memory while throwing - not much else can be done
        }
        eh.object = o;
        eh.exception_object.exception_class = dmdExceptionClass;
        debug (EH_personality) writeln("create(): %p", eh);
        return eh;
    }

    /**********************
     * Free ExceptionHeader that was created by create().
     * Params:
     *  eh = ExceptionHeader to free
     */
    static void free(ExceptionHeader* eh)
    {
        debug (EH_personality) writeln("free(%p)", eh);
        /* Smite contents even if subsequently free'd,
         * to ward off dangling pointer bugs.
         */
        *eh = ExceptionHeader.init;
        if (eh != &ehstorage)
            .free(eh);
    }

    /*************************
     * Push this onto stack of chained exceptions.
     */
    void push()
    {
        next = stack;
        stack = &this;
    }

    /************************
     * Pop and return top of chained exception stack.
     */
    static ExceptionHeader* pop()
    {
        auto eh = stack;
        stack = eh.next;
        return eh;
    }

    /*******************************
     * Convert from pointer to exception_object to pointer to ExceptionHeader
     * that it is embedded inside of.
     * Params:
     *  eo = pointer to exception_object field
     * Returns:
     *  pointer to ExceptionHeader that eo points into.
     */
    static ExceptionHeader* toExceptionHeader(_Unwind_Exception* eo)
    {
        return cast(ExceptionHeader*)(cast(void*)eo - ExceptionHeader.exception_object.offsetof);
    }
}

/*******************************************
 * The first thing a catch handler does is call this.
 * Params:
 *      exceptionObject = value passed to catch handler by unwinder
 * Returns:
 *      object that was caught
 */
// LDC: renamed from __dmd_begin_catch
extern(C) Throwable _d_eh_enter_catch(_Unwind_Exception* exceptionObject)
{
    ExceptionHeader *eh = ExceptionHeader.toExceptionHeader(exceptionObject);
    debug (EH_personality) writeln("__dmd_begin_catch(%p), object = %p", eh, eh.object);

    auto o = eh.object;
    // Remove our reference to the exception. We should not decrease its refcount,
    // because we pass the object on to the caller.
    eh.object = null;

    // Pop off of chain
    if (eh != ExceptionHeader.pop())
        terminate(__LINE__);                      // eh should have been at top of stack

    deleteException(&eh.exception_object);      // done with eh
    return o;
}

/****************************************
 * Called when fibers switch contexts.
 * Params:
 *      newContext = stack to switch to
 * Returns:
 *      previous value of stack
 */
extern(C) void* _d_eh_swapContextDwarf(void* newContext) nothrow @nogc
{
    auto old = ExceptionHeader.stack;
    ExceptionHeader.stack = cast(ExceptionHeader*)newContext;
    return old;
}


/*********************
 * Called by D code to throw an exception via
 * ---
 * throw o;
 * ---
 * Params:
 *      o = Object to throw
 * Returns:
 *      doesn't return
 */
// LDC: renamed from _d_throwdwarf
extern(C) void _d_throw_exception(Throwable o)
{
    ExceptionHeader *eh = ExceptionHeader.create(o);

    eh.push();  // add to thrown exception stack
    debug (EH_personality) writeln("_d_throwdwarf: eh = %p, eh.next = %p", eh, eh.next);

    /* Increment reference count if `o` is a refcounted Throwable
     */
    auto refcount = o.refcount();
    if (refcount)       // non-zero means it's refcounted
        o.refcount() = refcount + 1;

    /* Called by unwinder when exception object needs destruction by other than our code.
     */
    extern (C) static void exception_cleanup(_Unwind_Reason_Code reason, _Unwind_Exception* eo)
    {
        debug (EH_personality) writeln("exception_cleanup()");
        switch (reason)
        {
            case _URC_FATAL_PHASE1_ERROR:       // unknown error code
            case _URC_FATAL_PHASE2_ERROR:       // probably corruption
            default:                            // uh-oh
                terminate(__LINE__);            // C++ calls terminate() instead
                break;

            case _URC_FOREIGN_EXCEPTION_CAUGHT:
            case _URC_NO_REASON:
                auto eh = ExceptionHeader.toExceptionHeader(eo);
                ExceptionHeader.free(eh);
                break;
        }

    }

    eh.exception_object.exception_cleanup = &exception_cleanup;

    _d_createTrace(o, null);

    import ldc.intrinsics : llvm_wasm_throw;
    llvm_wasm_throw(0, &eh.exception_object);
}

// We inline the needed parts of libunwind here to avoid dependence
// We can't link libunwind because we need to override _Unwind_CallPersonality
//
// TODO: if/when the personality can be changed per function for Wasm in LLVM, use libunwind
// (so we can support C++ exceptions as well)

extern(C) struct _Unwind_LandingPadContext {
    // Input information to personality function
    size_t lpad_index; // landing pad index
    const(ubyte)* lsda;       // LSDA address

    // Output information computed by personality function
    size_t selector; // selector value
}

// Communication channel between compiler-generated user code and personality
// function
extern(C) _Unwind_LandingPadContext __wasm_lpad_context;

void deleteException(_Unwind_Exception *exception_object) {
    if (exception_object.exception_cleanup != null) {
        exception_object.exception_cleanup(_URC_FOREIGN_EXCEPTION_CAUGHT, exception_object);
    }
}


/*****************************************
 * "personality" function, specific to each language.
 *
 * WebAssembly does NOT use a standard Dwarf personality.
 *
 * On LLVM 23 and before, the personality is hardcoded to
 * __gxx_wasm_personality_v0, with code emitting calls to
 * _Unwind_CallPersonality. _Unwind_CallPersonality takes just
 * the exception object, and shims a call to the more standard personality.
 *
 * Starting LLVM 24, the personality is overridable per-function, with the
 * signature of the former _Unwind_CallPersonality, and the same ABI/behavior
 * expectations.
 *
 * Params:
 *      exceptionObject = language specific exception information
 * Returns:
 *      reason code
 */

// TODO: remove the mangle override once LLVM 24 comes out and LDC upgrades.
pragma(mangle, "_Unwind_CallPersonality")
extern (C) _Unwind_Reason_Code _d_eh_personality_wasm(_Unwind_Exception* exceptionObject)
{
    // Reset the selector.
    __wasm_lpad_context.selector = 0;

    _Unwind_Exception_Class exceptionClass = exceptionObject.exception_class;

    const(ubyte)* language_specific_data = __wasm_lpad_context.lsda;
    int handler;
    _Unwind_Ptr landing_pad;

    debug (EH_personality)
    {
        writeln("__dmd_personality_v0(actions = x%x, eo = %p, context = %p)", _UA_SEARCH_PHASE, exceptionObject, &__wasm_lpad_context);
        writeln("exceptionClass = x%08llx", exceptionClass);

        if (exceptionClass == dmdExceptionClass)
        {
            auto eh = ExceptionHeader.toExceptionHeader(exceptionObject);
            for (auto ehx = eh; ehx; ehx = ehx.next)
                writeln(" eh: %p next=%014p lsda=%p '%.*s'", ehx, ehx.next, ehx.languageSpecificData, cast(int) ehx.object.msg.length, ehx.object.msg.ptr);
        }
    }

    debug (EH_personality) writeln("lsda = %p", language_specific_data);

    /* Get instruction pointer (ip) at start of instruction that threw
     */
    auto ip = __wasm_lpad_context.lpad_index + 1;

    debug (EH_personality) writeln("ip = x%x", cast(int)(ip));
    debug (EH_personality) writeln("\tStart = %p, ipoff = %p, lsda = %p", 0, ip, language_specific_data);

    auto result = scanLSDA(language_specific_data, ip, exceptionClass,
        false,          // don't catch when forced unwinding
        true,          // search phase is looking for handlers
        exceptionObject,
        landing_pad,
        handler);

    final switch (result)
    {
        case LsdaResult.notFound:
            fprintf(cast()stderr, "not found\n");
            terminate(__LINE__);
            assert(0);

        case LsdaResult.foreign:
            terminate(__LINE__);
            assert(0);

        case LsdaResult.corrupt:
            fprintf(cast()stderr, "LSDA is corrupt\n");
            terminate(__LINE__);
            assert(0);

        case LsdaResult.noAction:
            debug (EH_personality) writeln("  no action");
            return _URC_CONTINUE_UNWIND;

        case LsdaResult.cleanup:
            debug (EH_personality) writeln("  cleanup");
            return _URC_CONTINUE_UNWIND;
            break;

        case LsdaResult.handler:
            debug (EH_personality) writeln("  handler");

            if (exceptionClass == dmdExceptionClass)
            {
                auto eh = ExceptionHeader.toExceptionHeader(exceptionObject);
                debug (EH_personality) writeln("   eh.lsda = %p, lsda = %p", eh.languageSpecificData, language_specific_data);
                eh.handler = handler;
                eh.languageSpecificData = language_specific_data;
                eh.landingPad = landing_pad;
            }

            // Wasm only uses a single phase (_UA_SEARCH_PHASE), so save the
            // results here.
            __wasm_lpad_context.selector = handler;

            return _URC_HANDLER_FOUND;
            break;
    }

    debug (EH_personality) writeln("  lsda = %p, landing_pad = %p, handler = %d", language_specific_data, landing_pad, handler);

    // Figure out what to do when there are multiple exceptions in flight
    if (exceptionClass == dmdExceptionClass)
    {
        auto eh = ExceptionHeader.toExceptionHeader(exceptionObject);
        debug (EH_personality) writeln(" '%.*s' next = %p", cast(int) eh.object.msg.length, eh.object.msg.ptr, eh.next);
        auto currentLsd = language_specific_data;
        bool bypassed = false;
        while (eh.next)
        {
            ExceptionHeader* ehn = eh.next;

            Error e = cast(Error)eh.object;
            if (e !is null && !cast(Error)ehn.object)
            {
                /* eh is an Error, ehn is not. Skip ehn.
                 */
                debug (EH_personality) writeln("bypass");
                currentLsd = ehn.languageSpecificData;

                // Continuing to construct the bypassed chain
                eh = ehn;
                bypassed = true;
                continue;
            }

            // Don't combine when the exceptions are from different functions
            if (currentLsd != ehn.languageSpecificData)
            {
                debug (EH_personality) writeln("break: %p %p", currentLsd, ehn.languageSpecificData);
                break;
            }

            else
            {
                debug (EH_personality) writeln("chain");
                // Append eh's object to ehn's object chain
                // And replace our exception object with in-flight one
                eh.object = Throwable.chainTogether(ehn.object, eh.object);

                if (ehn.handler != handler && !bypassed)
                {
                    handler = ehn.handler;

                    eh.handler = handler;
                    eh.languageSpecificData = language_specific_data;
                    eh.landingPad = landing_pad;
                }
            }

            // Remove ehn from threaded chain
            eh.next = ehn.next;
            debug (EH_personality) writeln("delete %p", ehn);
            deleteException(&ehn.exception_object); // discard ehn
        }
        if (bypassed)
        {
            eh = ExceptionHeader.toExceptionHeader(exceptionObject);
            Error e = cast(Error)eh.object;
            auto ehn = eh.next;
            e.bypassedException = ehn.object;
            eh.next = ehn.next;
            deleteException(&ehn.exception_object);
        }
    }

    // Set up registers and jump to cleanup or handler
    __wasm_lpad_context.selector = handler;

    return _URC_INSTALL_CONTEXT;
}

/*************************************************
 * Look at the chain of inflight exceptions and pick the class type that'll
 * be looked for in catch clauses.
 * Params:
 *      exceptionObject = language specific exception information
 *      currentLsd = pointer to LSDA table
 * Returns:
 *      class type to look for
 */
ClassInfo getClassInfo(_Unwind_Exception* exceptionObject, const(ubyte)* currentLsd)
{
    ExceptionHeader* eh = ExceptionHeader.toExceptionHeader(exceptionObject);
    Throwable ehobject = eh.object;
    debug (EH_personality) writeln("start: %p '%.*s'", ehobject, cast(int)(typeid(ehobject).info.name.length), ehobject.classinfo.info.name.ptr);
    for (ExceptionHeader* ehn = eh.next; ehn; ehn = ehn.next)
    {
        // like __dmd_personality_v0, don't combine when the exceptions are from different functions
        // Fixes "exception thrown and caught while inside finally block"
        // https://issues.dlang.org/show_bug.cgi?id=19831
        if (currentLsd != ehn.languageSpecificData)
        {
            debug (EH_personality) writeln("break: %p %p", currentLsd, ehn.languageSpecificData);
            break;
        }

        debug (EH_personality) writeln("ehn =   %p '%.*s'", ehn.object, cast(int)(typeid(ehn.object).info.name.length), ehn.object.classinfo.info.name.ptr);
        Error e = cast(Error)ehobject;
        if (e is null || (cast(Error)ehn.object) !is null)
        {
            ehobject = ehn.object;
        }
    }
    debug (EH_personality) writeln("end  : %p", ehobject);
    return typeid(ehobject);
}

/******************************
 * Decode Unsigned LEB128.
 * Params:
 *      p = pointer to data pointer, *p is updated
 *      to point past decoded value
 * Returns:
 *      decoded value
 * See_Also:
 *      https://en.wikipedia.org/wiki/LEB128
 */
_uleb128_t uLEB128(const(ubyte)** p)
{
    auto q = *p;
    _uleb128_t result = 0;
    uint shift = 0;
    while (1)
    {
        ubyte b = *q++;
        result |= cast(_uleb128_t)(b & 0x7F) << shift;
        if ((b & 0x80) == 0)
            break;
        shift += 7;
    }
    *p = q;
    return result;
}

/******************************
 * Decode Signed LEB128.
 * Params:
 *      p = pointer to data pointer, *p is updated
 *      to point past decoded value
 * Returns:
 *      decoded value
 * See_Also:
 *      https://en.wikipedia.org/wiki/LEB128
 */
_sleb128_t sLEB128(const(ubyte)** p)
{
    auto q = *p;
    ubyte b;

    _sleb128_t result = 0;
    uint shift = 0;
    while (1)
    {
        b = *q++;
        result |= cast(_sleb128_t)(b & 0x7F) << shift;
        shift += 7;
        if ((b & 0x80) == 0)
            break;
    }
    if (shift < result.sizeof * 8 && (b & 0x40))
        result |= -(cast(_sleb128_t)1 << shift);
    *p = q;
    return result;
}

enum
{
        DW_EH_PE_FORMAT_MASK    = 0x0F,
        DW_EH_PE_APPL_MASK      = 0x70,
        DW_EH_PE_indirect       = 0x80,

        DW_EH_PE_omit           = 0xFF,
        DW_EH_PE_ptr            = 0x00,
        DW_EH_PE_uleb128        = 0x01,
        DW_EH_PE_udata2         = 0x02,
        DW_EH_PE_udata4         = 0x03,
        DW_EH_PE_udata8         = 0x04,
        DW_EH_PE_sleb128        = 0x09,
        DW_EH_PE_sdata2         = 0x0A,
        DW_EH_PE_sdata4         = 0x0B,
        DW_EH_PE_sdata8         = 0x0C,

        DW_EH_PE_absptr         = 0x00,
        DW_EH_PE_pcrel          = 0x10,
        DW_EH_PE_textrel        = 0x20,
        DW_EH_PE_datarel        = 0x30,
        DW_EH_PE_funcrel        = 0x40,
        DW_EH_PE_aligned        = 0x50,
}


/**************************************************
 * Read and extract information from the LSDA (aka gcc_except_table section).
 * The dmd Call Site Table is structurally different from other implementations. It
 * is organized as nested ranges, and one ip can map to multiple ranges. The most
 * nested candidate is selected when searched. Other implementations have one candidate
 * per ip.
 * Params:
 *      lsda = pointer to LSDA table
 *      ip = offset from start of function at which exception happened
 *      exceptionClass = which language threw the exception
 *      cleanupsOnly = only look for cleanups
 *      preferHandler = if a handler encloses a cleanup, prefer the handler
 *      exceptionObject = language specific exception information
 *      landingPad = set to landing pad
 *      handler = set to index of which catch clause was matched
 * Returns:
 *      LsdaResult
 * See_Also:
 *      http://reverseengineering.stackexchange.com/questions/6311/how-to-recover-the-exception-info-from-gcc-except-table-and-eh-handle-sections
 *      http://www.airs.com/blog/archives/464
 *      https://anarcheuz.github.io/2015/02/15/ELF%20internals%20part%202%20-%20exception%20handling/
 */

LsdaResult scanLSDA(const(ubyte)* lsda, _Unwind_Ptr ip, _Unwind_Exception_Class exceptionClass,
        bool cleanupsOnly,
        bool preferHandler,
        _Unwind_Exception* exceptionObject,
        out _Unwind_Ptr landingPad, out int handler)
{
    auto p = lsda;
    if (!p)
        return LsdaResult.noAction;

    _Unwind_Ptr dw_pe_value(ubyte pe)
    {
        switch (pe)
        {
            case DW_EH_PE_sdata2:   return readUnaligned!(short,  true)(p);
            case DW_EH_PE_udata2:   return readUnaligned!(ushort, true)(p);
            case DW_EH_PE_sdata4:   return readUnaligned!(int,    true)(p);
            case DW_EH_PE_udata4:   return readUnaligned!(uint,   true)(p);
            case DW_EH_PE_sdata8:   return readUnaligned!(long,   true)(p);
            case DW_EH_PE_udata8:   return readUnaligned!(ulong,  true)(p);
            case DW_EH_PE_sleb128:  return cast(_Unwind_Ptr) sLEB128(&p);
            case DW_EH_PE_uleb128:  return cast(_Unwind_Ptr) uLEB128(&p);
            case DW_EH_PE_ptr:      if (size_t.sizeof == 8)
                                        goto case DW_EH_PE_udata8;
                                    else
                                        goto case DW_EH_PE_udata4;
            default:
                terminate(__LINE__);
                return 0;
        }
    }

    ubyte LPstart = *p++;

    _Unwind_Ptr LPbase = 0;
    if (LPstart != DW_EH_PE_omit)
    {
        LPbase = dw_pe_value(LPstart);
    }

    ubyte TType = *p++;
    _Unwind_Ptr TTbase = 0;
    _Unwind_Ptr TToffset = 0;
    if (TType != DW_EH_PE_omit)
    {
        TTbase = uLEB128(&p);
        TToffset = (p - lsda) + TTbase;
    }
    debug (EH_personality) writeln("  TType = x%x, TTbase = x%x", TType, cast(int)TTbase);

    ubyte CallSiteFormat = *p++;

    _Unwind_Ptr CallSiteTableSize = dw_pe_value(DW_EH_PE_uleb128);
    debug (EH_personality) writeln("  CallSiteFormat = x%x, CallSiteTableSize = x%x", CallSiteFormat, cast(int)CallSiteTableSize);

    _Unwind_Ptr ipoffset = ip - LPbase;
    debug (EH_personality) writeln("ipoffset = x%x", cast(int)ipoffset);
    bool noAction = false;
    auto tt = lsda + TToffset;
    const(ubyte)* pActionTable = p + CallSiteTableSize;

    version (LDC)
    {
        // Returns false if a filter (handler < 0) is encountered (not supported).
        bool finalize(_Unwind_Ptr LandingPad, _Unwind_Ptr ActionRecordPtr)
        {
            // If there is no landing pad for this part of the frame, continue with the next level.
            if (!LandingPad)
            {
                noAction = true;
                return true;
            }

            if (ActionRecordPtr)                // if saw a catch
            {
                if (cleanupsOnly)
                {
                    noAction = true;
                    return true;
                }

                auto h = actionTableLookup(exceptionObject, cast(uint)ActionRecordPtr, pActionTable, tt, TType, exceptionClass, lsda);
                if (h < 0)
                {
                    fprintf(cast()stderr, "negative handler\n");
                    return false;
                }

                // The catch (or cleanup for h == 0) is good
                noAction = false;
                landingPad = LandingPad;
                handler = h;
            }
            else                                // if saw a cleanup
            {
                noAction = false;
                landingPad = LandingPad;
            }

            return true;
        }
    }

    if (TType == DW_EH_PE_omit)
    {
        // Used for simple cleanup actions (finally, dtors) that don't care
        // about exception type
        tt = null;
    }

    if (ip < LPbase) // ipoffset is unsigned
    {
        noAction = true;
    }
    else if (ipoffset == 0)
    {
        // If ip is not present in the table, call terminate.
        terminate(__LINE__);
    }
    else
    {
        _uleb128_t callsite_lp, callsite_action;
        do
        {
            callsite_lp = uLEB128(&p);
            callsite_action = uLEB128(&p);
            debug (EH_personality)
            {
                writeln(" XT: ipoffset = x%x, landing pad = x%x, action = x%x",
                    cast(int)ipoffset, cast(int)callsite_lp, cast(int)callsite_action);
            }
        }
        while (--ipoffset);

        const success = finalize(callsite_lp + 1, callsite_action);
        if (!success)
            return LsdaResult.corrupt;
    }

    if (noAction)
    {
        assert(!landingPad && !handler);
        return LsdaResult.noAction;
    }

    if (landingPad)
        return handler ? LsdaResult.handler : LsdaResult.cleanup;

    return LsdaResult.notFound;
}

/********************************************
 * Look up classType in Action Table.
 * Params:
 *      exceptionObject = language specific exception information
 *      actionRecordPtr = starting index in Action Table + 1
 *      pActionTable = pointer to start of Action Table
 *      tt = pointer past end of Type Table
 *      TType = encoding of entries in Type Table
 *      exceptionClass = which language threw the exception
 *      lsda = pointer to LSDA table
 * Returns:
 *      - &gt;=1 means the handler index of the classType
 *      - 0 means classType is not in the Action Table
 *      - &lt;0 means corrupt
 */
int actionTableLookup(_Unwind_Exception* exceptionObject, uint actionRecordPtr, const(ubyte)* pActionTable,
                      const(ubyte)* tt, ubyte TType, _Unwind_Exception_Class exceptionClass, const(ubyte)* lsda)
{
    debug (EH_personality)
    {
        writeln("actionTableLookup(actionRecordPtr = %d, pActionTable = %p, tt = %p)",
            actionRecordPtr, pActionTable, tt);
    }
    assert(pActionTable < tt);

    ClassInfo thrownType;
    if (exceptionClass == dmdExceptionClass)
    {
        thrownType = getClassInfo(exceptionObject, lsda);
    }

    for (auto ap = pActionTable + actionRecordPtr - 1; 1; )
    {
        assert(pActionTable <= ap && ap < tt);

        auto TypeFilter = sLEB128(&ap);
        auto apn = ap;
        auto NextRecordPtr = sLEB128(&ap);

        debug (EH_personality) writeln(" at: TypeFilter = %d, NextRecordPtr = %d", cast(int)TypeFilter, cast(int)NextRecordPtr);

        version (LDC)
        {
            // zero means cleanup
            if (TypeFilter == 0)
                return 0;
        }
        if (TypeFilter <= 0)                    // should never happen with DMD generated tables
        {
            fprintf(cast()stderr, "TypeFilter = %d\n", cast(int)TypeFilter);
            return -1;                          // corrupt
        }

        /* TypeFilter is negative index from TToffset,
         * which is where the ClassInfo is stored
         */
        _Unwind_Ptr entry;
        const(ubyte)* tt2;
        switch (TType & DW_EH_PE_FORMAT_MASK)
        {
            case DW_EH_PE_sdata2:   entry = readUnaligned!(short,  false)(tt2 = tt - TypeFilter * 2); break;
            case DW_EH_PE_udata2:   entry = readUnaligned!(ushort, false)(tt2 = tt - TypeFilter * 2); break;
            case DW_EH_PE_sdata4:   entry = readUnaligned!(int,    false)(tt2 = tt - TypeFilter * 4); break;
            case DW_EH_PE_udata4:   entry = readUnaligned!(uint,   false)(tt2 = tt - TypeFilter * 4); break;
            case DW_EH_PE_sdata8:   entry = readUnaligned!(long,   false)(tt2 = tt - TypeFilter * 8); break;
            case DW_EH_PE_udata8:   entry = readUnaligned!(ulong,  false)(tt2 = tt - TypeFilter * 8); break;
            case DW_EH_PE_ptr:      if (size_t.sizeof == 8)
                                        goto case DW_EH_PE_udata8;
                                    else
                                        goto case DW_EH_PE_udata4;
            default:
                fprintf(cast()stderr, "TType = x%x\n", TType);
                return -1;      // corrupt
        }
        if (!entry)             // the 'catch all' type
            return -1;          // corrupt: should never happen with DMD, which explicitly uses Throwable

        switch (TType & DW_EH_PE_APPL_MASK)
        {
            case DW_EH_PE_absptr:
                break;

            case DW_EH_PE_pcrel:
                entry += cast(_Unwind_Ptr)tt2;
                break;

            default:
                return -1;
        }
        if (TType & DW_EH_PE_indirect)
            entry = *cast(_Unwind_Ptr*)entry;

        ClassInfo ci = cast(ClassInfo)cast(void*)(entry);

        if (exceptionClass == dmdExceptionClass && _d_isbaseof(thrownType, ci))
            return cast(int)TypeFilter; // found it

        if (!NextRecordPtr)
            return 0;                   // catch not found

        ap = apn + NextRecordPtr;
    }
    assert(false); // All other branches return
}

enum LsdaResult
{
    notFound,   // ip was not found in the LSDA - an exception shouldn't have happened
    foreign,    // found a result we cannot handle
    corrupt,    // the tables are corrupt
    noAction,   // found, but no action needed (i.e. no cleanup nor handler)
    cleanup,    // cleanup found (i.e. finally or destructor)
    handler,    // handler found (i.e. a catch)
}

void terminate(uint line) @nogc
{
    printf("dwarfeh(%u) fatal error\n", line);
    abort();     // unceremoniously exit
}
