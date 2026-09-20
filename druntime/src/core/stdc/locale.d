/**
 * D header file for C99.
 *
 * $(C_HEADER_DESCRIPTION pubs.opengroup.org/onlinepubs/009695399/basedefs/_locale.h.html, _locale.h)
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors:   Sean Kelly
 * Source:    $(DRUNTIMESRC core/stdc/_locale.d)
 * Standards: ISO/IEC 9899:1999 (E)
 */

module core.stdc.locale;

version (OSX)
    version = Darwin;
else version (iOS)
    version = Darwin;
else version (TVOS)
    version = Darwin;
else version (WatchOS)
    version = Darwin;

extern (C):
@trusted: // Only setlocale operates on C strings.
nothrow:
@nogc:

///

struct lconv
{
    char* decimal_point;
    char* thousands_sep;
    char* grouping;
    char* int_curr_symbol;
    char* currency_symbol;
    char* mon_decimal_point;
    char* mon_thousands_sep;
    char* mon_grouping;
    char* positive_sign;
    char* negative_sign;
    byte  int_frac_digits;
    byte  frac_digits;
    byte  p_cs_precedes;
    byte  p_sep_by_space;
    byte  n_cs_precedes;
    byte  n_sep_by_space;
    byte  p_sign_posn;
    byte  n_sign_posn;
    byte  int_p_cs_precedes;
    byte  int_p_sep_by_space;
    byte  int_n_cs_precedes;
    byte  int_n_sep_by_space;
    byte  int_p_sign_posn;
    byte  int_n_sign_posn;
}

version (CRuntime_WASI)
{
    ///
    enum LC_CTYPE          = 0;
    ///
    enum LC_NUMERIC        = 1;
    ///
    enum LC_TIME           = 2;
    ///
    enum LC_COLLATE        = 3;
    ///
    enum LC_MONETARY       = 4;
    ///
    enum LC_MESSAGES       = 5;
    ///
    enum LC_ALL            = 6;
}
else
{
    static assert(false, "Unsupported platform");
}

///
@system char*  setlocale(int category, const scope char* locale);
///
lconv* localeconv();
