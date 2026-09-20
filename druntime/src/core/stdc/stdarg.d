/**
 * D header file for C99.
 *
 * $(C_HEADER_DESCRIPTION pubs.opengroup.org/onlinepubs/009695399/basedefs/_stdarg.h.html, _stdarg.h)
 *
 * Copyright: Copyright Digital Mars 2000 - 2020.
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Walter Bright, Hauke Duden
 * Standards: ISO/IEC 9899:1999 (E)
 * Source: $(DRUNTIMESRC core/stdc/_stdarg.d)
 */

module core.stdc.stdarg;

@nogc:
nothrow:

T alignUp(size_t alignment = size_t.sizeof, T)(T base) pure
{
    enum mask = alignment - 1;
    static assert(alignment > 0 && (alignment & mask) == 0, "alignment must be a power of 2");
    auto b = cast(size_t) base;
    b = (b + mask) & ~mask;
    return cast(T) b;
}

unittest
{
    assert(1.alignUp == size_t.sizeof);
    assert(31.alignUp!16 == 32);
    assert(32.alignUp!16 == 32);
    assert(33.alignUp!16 == 48);
    assert((-9).alignUp!8 == -8);
}

/**
 * The argument pointer type.
 */
alias va_list = char*; // incl. unknown platforms

/**
 * Initialize ap.
 * parmn should be the last named parameter.
 */
version (LDC)
{
    pragma(LDC_va_start)
    void va_start(T)(out va_list ap, ref T parmn) @nogc;
} else static assert (0);

/**
 * Retrieve and return the next value that is of type T.
 */
T va_arg(T)(ref va_list ap)
{
    version (WebAssembly)
    {
        ap = ap.alignUp!(T.alignof);
        auto p = cast(T*) ap;
        ap += T.sizeof.alignUp!4; // align up to int (4-bytes, even on wasm64)

        return *p;
    }
    else
        static assert(0, "Unsupported platform");
}


/**
 * Retrieve and store in parmn the next value that is of type T.
 */
void va_arg(T)(ref va_list ap, ref T parmn)
{
    parmn = va_arg!T(ap);
}


/**
 * End use of ap.
 */
version (LDC)
{
    pragma(LDC_va_end)
    void va_end(va_list ap);
}
else static assert (0);


/**
 * Make a copy of ap.
 */
version (LDC)
{
    pragma(LDC_va_copy)
    void va_copy(out va_list dest, va_list src);
}
else static assert(0);
