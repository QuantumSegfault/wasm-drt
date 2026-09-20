/**
 * D header file for C99.
 *
 * $(C_HEADER_DESCRIPTION pubs.opengroup.org/onlinepubs/009695399/basedefs/_errno.h.html, _errno.h)
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors:   Sean Kelly, Alex Rønne Petersen
 * Source:    $(DRUNTIMESRC core/stdc/_errno.d)
 * Standards: ISO/IEC 9899:1999 (E)
 */

module core.stdc.errno;

@trusted: // Only manipulates errno.
nothrow:
@nogc:

version (CRuntime_WASI)
{
    extern (C)
    {
        ref int __errno_location();
        alias errno = __errno_location;
    }
}
else static assert(0);

extern (C):


version (CRuntime_WASI)
{
    enum E2BIG           = 1;
    enum EACCES          = 2;
    enum EADDRINUSE      = 3;
    enum EADDRNOTAVAIL   = 4;
    enum EAFNOSUPPORT    = 5;
    enum EAGAIN          = 6;
    enum EALREADY        = 7;
    enum EBADF           = 8;
    enum EBADMSG         = 9;
    enum EBUSY           = 10;
    enum ECANCELED       = 11;
    enum ECHILD          = 12;
    enum ECONNABORTED    = 13;
    enum ECONNREFUSED    = 14;
    enum ECONNRESET      = 15;
    enum EDEADLK         = 16;
    enum EDESTADDRREQ    = 17;
    enum EDOM            = 18;
    enum EDQUOT          = 19;
    enum EEXIST          = 20;
    enum EFAULT          = 21;
    enum EFBIG           = 22;
    enum EHOSTUNREACH    = 23;
    enum EIDRM           = 24;
    enum EILSEQ          = 25;
    enum EINPROGRESS     = 26;
    enum EINTR           = 27;
    enum EINVAL          = 28;
    enum EIO             = 29;
    enum EISCONN         = 30;
    enum EISDIR          = 31;
    enum ELOOP           = 32;
    enum EMFILE          = 33;
    enum EMLINK          = 34;
    enum EMSGSIZE        = 35;
    enum EMULTIHOP       = 36;
    enum ENAMETOOLONG    = 37;
    enum ENETDOWN        = 38;
    enum ENETRESET       = 39;
    enum ENETUNREACH     = 40;
    enum ENFILE          = 41;
    enum ENOBUFS         = 42;
    enum ENODEV          = 43;
    enum ENOENT          = 44;
    enum ENOEXEC         = 45;
    enum ENOLCK          = 46;
    enum ENOLINK         = 47;
    enum ENOMEM          = 48;
    enum ENOMSG          = 49;
    enum ENOPROTOOPT     = 50;
    enum ENOSPC          = 51;
    enum ENOSYS          = 52;
    enum ENOTCONN        = 53;
    enum ENOTDIR         = 54;
    enum ENOTEMPTY       = 55;
    enum ENOTRECOVERABLE = 56;
    enum ENOTSOCK        = 57;
    enum ENOTSUP         = 58;
    enum ENOTTY          = 59;
    enum ENXIO           = 60;
    enum EOVERFLOW       = 61;
    enum EOWNERDEAD      = 62;
    enum EPERM           = 63;
    enum EPIPE           = 64;
    enum EPROTO          = 65;
    enum EPROTONOSUPPORT = 66;
    enum EPROTOTYPE      = 67;
    enum ERANGE          = 68;
    enum EROFS           = 69;
    enum ESPIPE          = 70;
    enum ESRCH           = 71;
    enum ESTALE          = 72;
    enum ETIMEDOUT       = 73;
    enum ETXTBSY         = 74;
    enum EXDEV           = 75;
    enum ENOTCAPABLE     = 76;

    enum EOPNOTSUPP      = ENOTSUP;
    enum EWOULDBLOCK     = EAGAIN;
}
else version (Emscripten)
{
    // mostly WASI compatible:
    enum E2BIG           = 1;
    enum EACCES          = 2;
    enum EADDRINUSE      = 3;
    enum EADDRNOTAVAIL   = 4;
    enum EAFNOSUPPORT    = 5;
    enum EAGAIN          = 6;
    enum EALREADY        = 7;
    enum EBADF           = 8;
    enum EBADMSG         = 9;
    enum EBUSY           = 10;
    enum ECANCELED       = 11;
    enum ECHILD          = 12;
    enum ECONNABORTED    = 13;
    enum ECONNREFUSED    = 14;
    enum ECONNRESET      = 15;
    enum EDEADLK         = 16;
    enum EDESTADDRREQ    = 17;
    enum EDOM            = 18;
    enum EDQUOT          = 19;
    enum EEXIST          = 20;
    enum EFAULT          = 21;
    enum EFBIG           = 22;
    enum EHOSTUNREACH    = 23;
    enum EIDRM           = 24;
    enum EILSEQ          = 25;
    enum EINPROGRESS     = 26;
    enum EINTR           = 27;
    enum EINVAL          = 28;
    enum EIO             = 29;
    enum EISCONN         = 30;
    enum EISDIR          = 31;
    enum ELOOP           = 32;
    enum EMFILE          = 33;
    enum EMLINK          = 34;
    enum EMSGSIZE        = 35;
    enum EMULTIHOP       = 36;
    enum ENAMETOOLONG    = 37;
    enum ENETDOWN        = 38;
    enum ENETRESET       = 39;
    enum ENETUNREACH     = 40;
    enum ENFILE          = 41;
    enum ENOBUFS         = 42;
    enum ENODEV          = 43;
    enum ENOENT          = 44;
    enum ENOEXEC         = 45;
    enum ENOLCK          = 46;
    enum ENOLINK         = 47;
    enum ENOMEM          = 48;
    enum ENOMSG          = 49;
    enum ENOPROTOOPT     = 50;
    enum ENOSPC          = 51;
    enum ENOSYS          = 52;
    enum ENOTCONN        = 53;
    enum ENOTDIR         = 54;
    enum ENOTEMPTY       = 55;
    enum ENOTRECOVERABLE = 56;
    enum ENOTSOCK        = 57;
    // different (see below): ENOTSUP
    enum ENOTTY          = 59;
    enum ENXIO           = 60;
    enum EOVERFLOW       = 61;
    enum EOWNERDEAD      = 62;
    enum EPERM           = 63;
    enum EPIPE           = 64;
    enum EPROTO          = 65;
    enum EPROTONOSUPPORT = 66;
    enum EPROTOTYPE      = 67;
    enum ERANGE          = 68;
    enum EROFS           = 69;
    enum ESPIPE          = 70;
    enum ESRCH           = 71;
    enum ESTALE          = 72;
    enum ETIMEDOUT       = 73;
    enum ETXTBSY         = 74;
    enum EXDEV           = 75;
    // not defined: ENOTCAPABLE

    // extra codes:
    enum ENOSTR          = 100;
    enum EBFONT          = 101;
    enum EBADSLT         = 102;
    enum EBADRQC         = 103;
    enum ENOANO          = 104;
    enum ENOTBLK         = 105;
    enum ECHRNG          = 106;
    enum EL3HLT          = 107;
    enum EL3RST          = 108;
    enum ELNRNG          = 109;
    enum EUNATCH         = 110;
    enum ENOCSI          = 111;
    enum EL2HLT          = 112;
    enum EBADE           = 113;
    enum EBADR           = 114;
    enum EXFULL          = 115;
    enum ENODATA         = 116;
    enum ETIME           = 117;
    enum ENOSR           = 118;
    enum ENONET          = 119;
    enum ENOPKG          = 120;
    enum EREMOTE         = 121;
    enum EADV            = 122;
    enum ESRMNT          = 123;
    enum ECOMM           = 124;
    enum EDOTDOT         = 125;
    enum ENOTUNIQ        = 126;
    enum EBADFD          = 127;
    enum EREMCHG         = 128;
    enum ELIBACC         = 129;
    enum ELIBBAD         = 130;
    enum ELIBSCN         = 131;
    enum ELIBMAX         = 132;
    enum ELIBEXEC        = 133;
    enum ERESTART        = 134;
    enum ESTRPIPE        = 135;
    enum EUSERS          = 136;
    enum ESOCKTNOSUPPORT = 137;
    enum EOPNOTSUPP      = 138;
    enum EPFNOSUPPORT    = 139;
    enum ESHUTDOWN       = 140;
    enum ETOOMANYREFS    = 141;
    enum EHOSTDOWN       = 142;
    enum EUCLEAN         = 143;
    enum ENOTNAM         = 144;
    enum ENAVAIL         = 145;
    enum EISNAM          = 146;
    enum EREMOTEIO       = 147;
    enum ENOMEDIUM       = 148;
    enum EMEDIUMTYPE     = 149;
    enum ENOKEY          = 150;
    enum EKEYEXPIRED     = 151;
    enum EKEYREVOKED     = 152;
    enum EKEYREJECTED    = 153;
    enum ERFKILL         = 154;
    enum EHWPOISON       = 155;
    enum EL2NSYNC        = 156;

    // musl aliases:
    enum EWOULDBLOCK     = EAGAIN;
    enum EDEADLOCK       = EDEADLK;
    enum ENOTSUP         = EOPNOTSUPP;
}
else
{
    static assert(false, "Unsupported platform");
}
