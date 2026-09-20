/**
 * D header file for C99 <stdio.h>
 *
 * $(C_HEADER_DESCRIPTION pubs.opengroup.org/onlinepubs/009695399/basedefs/_stdio.h.html, _stdio.h)
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors:   Sean Kelly,
 *            Alex Rønne Petersen
 * Source:    $(DRUNTIMESRC core/stdc/_stdio.d)
 * Standards: ISO/IEC 9899:1999 (E)
 */

module core.stdc.stdio;

private
{
    import core.stdc.config;
    import core.stdc.stdarg; // for va_list
    import core.stdc.stdint : intptr_t;
}

extern (C):
nothrow:
@nogc:

version (CRuntime_WASI)
{
    enum
    {
        ///
        BUFSIZ       = 1024,
        ///
        EOF          = -1,
        ///
        FOPEN_MAX    = 1000,
        ///
        FILENAME_MAX = 4096,
    }
}
else
{
    static assert( false, "Unsupported platform" );
}

enum
{
    /// Offset is relative to the beginning
    SEEK_SET,
    /// Offset is relative to the current position
    SEEK_CUR,
    /// Offset is relative to the end
    SEEK_END
}

version (CRuntime_WASI)
{
    union fpos_t
    {
        char[16] __opaque = 0;
        double __align;
    }
    struct _IO_FILE;

    ///
    alias _iobuf = _IO_FILE; // needed for phobos
    ///
    alias FILE = shared(_IO_FILE);
}
else
{
    static assert( false, "Unsupported platform" );
}

enum
{
    ///
    _F_RDWR = 0x0003, // non-standard
    ///
    _F_READ = 0x0001, // non-standard
    ///
    _F_WRIT = 0x0002, // non-standard
    ///
    _F_BUF  = 0x0004, // non-standard
    ///
    _F_LBUF = 0x0008, // non-standard
    ///
    _F_ERR  = 0x0010, // non-standard
    ///
    _F_EOF  = 0x0020, // non-standard
    ///
    _F_BIN  = 0x0040, // non-standard
    ///
    _F_IN   = 0x0080, // non-standard
    ///
    _F_OUT  = 0x0100, // non-standard
    ///
    _F_TERM = 0x0200, // non-standard
}

version (CRuntime_WASI)
{
    // needs tail const
    extern shared FILE* stdin;
    ///
    extern shared FILE* stdout;
    ///
    extern shared FILE* stderr;
    enum
    {
        ///
        _IOFBF = 0,
        ///
        _IOLBF = 1,
        ///
        _IONBF = 2,
    }
}
else
{
    static assert( false, "Unsupported platform" );
}

///
int remove(scope const char* filename);
///
int rename(scope const char* from, scope const char* to);

///
@trusted FILE* tmpfile(); // No unsafe pointer manipulation.
///
char* tmpnam(char* s);

///
int   fclose(FILE* stream);

// No unsafe pointer manipulation.
@trusted
{
    ///
    int   fflush(FILE* stream);
}

///
FILE* fopen(scope const char* filename, scope const char* mode);
///
FILE* freopen(scope const char* filename, scope const char* mode, FILE* stream);

///
void setbuf(FILE* stream, char* buf);
///
int  setvbuf(FILE* stream, char* buf, int mode, size_t size);

///
pragma(printf)
int fprintf(FILE* stream, scope const char* format, scope const ...);
///
pragma(scanf)
int fscanf(FILE* stream, scope const char* format, scope ...);
///
pragma(printf)
int sprintf(scope char* s, scope const char* format, scope const ...);
///
pragma(scanf)
int sscanf(scope const char* s, scope const char* format, scope ...);
///
pragma(printf)
int vfprintf(FILE* stream, scope const char* format, va_list arg);
///
pragma(scanf)
int vfscanf(FILE* stream, scope const char* format, va_list arg);
///
pragma(printf)
int vsprintf(scope char* s, scope const char* format, va_list arg);
///
pragma(scanf)
int vsscanf(scope const char* s, scope const char* format, va_list arg);
///
pragma(printf)
int vprintf(scope const char* format, va_list arg);
///
pragma(scanf)
int vscanf(scope const char* format, va_list arg);
///
pragma(printf)
int printf(scope const char* format, scope const ...);
///
pragma(scanf)
int scanf(scope const char* format, scope ...);

// No unsafe pointer manipulation.
@trusted
{
    ///
    int fgetc(FILE* stream);
    ///
    int fputc(int c, FILE* stream);
}

///
char* fgets(char* s, int n, FILE* stream);
///
int   fputs(scope const char* s, FILE* stream);
///
char* gets(char* s);
///
int   puts(scope const char* s);

// No unsafe pointer manipulation.
extern (D) @trusted
{
    ///
    int getchar()()                 { return getc(stdin);     }
    ///
    int putchar()(int c)            { return putc(c,stdout);  }
}

///
alias getc = fgetc;
///
alias putc = fputc;

///
@trusted int ungetc(int c, FILE* stream); // No unsafe pointer manipulation.

///
size_t fread(scope void* ptr, size_t size, size_t nmemb, FILE* stream);
///
size_t fwrite(scope const void* ptr, size_t size, size_t nmemb, FILE* stream);

// No unsafe pointer manipulation.
@trusted
{
    ///
    int fgetpos(FILE* stream, scope fpos_t * pos);
    ///
    int fsetpos(FILE* stream, scope const fpos_t* pos);

    ///
    int    fseek(FILE* stream, c_long offset, int whence);
    ///
    c_long ftell(FILE* stream);
}

version (WASI)
{
    // No unsafe pointer manipulation.
    @trusted
    {
        ///
        void rewind(FILE* stream);
        ///
        pure void clearerr(FILE* stream);
        ///
        pure int  feof(FILE* stream);
        ///
        pure int  ferror(FILE* stream);
        ///
        int  fileno(FILE *);
    }

    ///
    int  snprintf(scope char* s, size_t n, scope const char* format, ...);
    ///
    int  vsnprintf(scope char* s, size_t n, scope const char* format, va_list arg);
}
else
{
    static assert( false, "Unsupported platform" );
}

///
void perror(scope const char* s);
