/**
 * D header file for C99.
 *
 * $(C_HEADER_DESCRIPTION pubs.opengroup.org/onlinepubs/009695399/basedefs/_assert.h.html, _assert.h)
 *
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Source:    $(DRUNTIMESRC core/stdc/_assert_.d)
 * Standards: ISO/IEC 9899:1999 (E)
 */

/****************************
 * These are the various functions called by the assert() macro.
 */

module core.stdc.assert_;

extern (C):
@trusted:
nothrow:
@nogc:

version (CRuntime_WASI)
{
     /***
     * Assert failure function in the WASI C library.
     */
    noreturn __assert_fail(const(char)* exp, const(char)* file, uint line, const(char)* func);
}
else
{
    static assert(0);
}
