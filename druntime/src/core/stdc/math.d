/**
 * D header file for C99.
 *
 * $(C_HEADER_DESCRIPTION pubs.opengroup.org/onlinepubs/009695399/basedefs/_math.h.html, _math.h)
 *
 * Copyright: Copyright Sean Kelly 2005 - 2012.
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors:   Sean Kelly
 * Source:    $(DRUNTIMESRC core/stdc/_math.d)
 */

module core.stdc.math;

import core.stdc.config;

extern (C):
@trusted: // All functions here operate on floating point and integer values only.
nothrow:
@nogc:

///
alias float_t = float;
///
alias double_t = double;

///
enum double HUGE_VAL      = double.infinity;
///
enum double HUGE_VALF     = float.infinity;
///
enum double HUGE_VALL     = real.infinity;

///
enum float INFINITY       = float.infinity;
///
enum float NAN            = float.nan;

///
enum int FP_ILOGB0        = int.min;
///
enum int FP_ILOGBNAN      = int.min;

///
enum int MATH_ERRNO       = 1;
///
enum int MATH_ERREXCEPT   = 2;

version (WASI) // incl. Emscripten
{
    ///
    enum int math_errhandling = 2;
}
else static assert(0);

version (CRuntime_WASI)
{
    enum
    {
        ///
        FP_NAN,
        ///
        FP_INFINITE,
        ///
        FP_ZERO,
        ///
        FP_SUBNORMAL,
        ///
        FP_NORMAL,
    }

    enum
    {
        ///
        FP_FAST_FMA  = 0,
        ///
        FP_FAST_FMAF = 0,
        ///
        FP_FAST_FMAL = 0,
    }

    // In `wasi_libc`, these are defined as macros redirecting to Clang builtins
    // We approximate the builtins based on their definitions in
    // https://github.com/llvm/llvm-project/blob/main/clang/lib/CodeGen/CGBuiltin.cpp
    version(LDC)
    extern (D) pure pragma(inline, true) {
        // __builtin_fpclassify(FP_NAN, FP_INFINITE, FP_NORMAL, FP_SUBNORMAL, FP_ZERO, val)
        // Codegen only matches at -O1 or greater
        int fpclassify(T)(T val) {
            import ldc.llvmasm : __ir_pure;
            import ldc.intrinsics : llvm_fabs;

            if (val == T(0.0)) return FP_ZERO;
            if (val != val) return FP_NAN;

            auto fabsVal = llvm_fabs(val);

            if (fabsVal == T.infinity) return FP_INFINITE;

            // Work around to deal with https://wiki.dlang.org/Cross-compiling_with_LDC#Limitations
            // real.min_normal ends up underflowing to zero
            static if (is(T == real))
                return __ir_pure!(`
                    %cmp = fcmp uge fp128 %0, f0x00010000000000000000000000000000
                    ret i1 %cmp
                `, bool)(val) ? FP_NORMAL : FP_SUBNORMAL;
            else return fabsVal >= T.min_normal ? FP_NORMAL : FP_SUBNORMAL;
        }

        import ldc.intrinsics : llvm_is_fpclass;
        bool isinf(T)(T val) pure => llvm_is_fpclass(val, (1 << 2) | (1 << 9)); // __builtin_isinf
        bool isnan(T)(T val) pure => llvm_is_fpclass(val, (1 << 0) | (1 << 1)); // __builtin_isnan
        bool isnormal(T)(T val) pure => llvm_is_fpclass(val, (1 << 3) | (1 << 8)); // __builtin_isnormal
        bool isfinite(T)(T val) pure => llvm_is_fpclass(val, (1 << 3) | (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7) | (1 << 8)); // __builtin_isfinite

        bool signbit(float val) pure => *cast(int*)&val < 0; // __builtin_signbit
        bool signbit(double val) pure => *cast(long*)&val < 0; // __builtin_signbit

        // __builtin_signbit
        // Uses LLVM IR to access i128 ops directly
        // approximately: *cast(cent*)&val < 0
        import ldc.llvmasm : __ir_pure;
        bool signbit(real val) pure => __ir_pure!(`
            %cast = bitcast fp128 %0 to i128
            %cmp = icmp slt i128 %cast, 0
            ret i1 %cmp
        `, bool)(val);
    }
    else static assert(0, "Unknown D compiler for WASI");
} else static assert(0);

extern (D)
{
    //int isgreater(real-floating x, real-floating y);
    ///
    pure int isgreater()(float x, float y)        { return x > y; }
    ///
    pure int isgreater()(double x, double y)      { return x > y; }
    ///
    pure int isgreater()(real x, real y)          { return x > y; }

    //int isgreaterequal(real-floating x, real-floating y);
    ///
    pure int isgreaterequal()(float x, float y)   { return x >= y; }
    ///
    pure int isgreaterequal()(double x, double y) { return x >= y; }
    ///
    pure int isgreaterequal()(real x, real y)     { return x >= y; }

    //int isless(real-floating x, real-floating y);
    ///
    pure int isless()(float x, float y)           { return x < y; }
    ///
    pure int isless()(double x, double y)         { return x < y; }
    ///
    pure int isless()(real x, real y)             { return x < y; }

    //int islessequal(real-floating x, real-floating y);
    ///
    pure int islessequal()(float x, float y)      { return x <= y; }
    ///
    pure int islessequal()(double x, double y)    { return x <= y; }
    ///
    pure int islessequal()(real x, real y)        { return x <= y; }

    //int islessgreater(real-floating x, real-floating y);
    ///
    pure int islessgreater()(float x, float y)    { return x != y && !isunordered(x, y); }
    ///
    pure int islessgreater()(double x, double y)  { return x != y && !isunordered(x, y); }
    ///
    pure int islessgreater()(real x, real y)      { return x != y && !isunordered(x, y); }

    //int isunordered(real-floating x, real-floating y);
    ///
    pure int isunordered()(float x, float y)      { return isnan(x) || isnan(y); }
    ///
    pure int isunordered()(double x, double y)    { return isnan(x) || isnan(y); }
    ///
    pure int isunordered()(real x, real y)        { return isnan(x) || isnan(y); }
}


///
double  acos(double x);
///
float   acosf(float x);

///
double  asin(double x);
///
float   asinf(float x);

///
pure double  atan(double x);
///
pure float   atanf(float x);

///
double  atan2(double y, double x);
///
float   atan2f(float y, float x);

///
pure double  cos(double x);
///
pure float   cosf(float x);

///
pure double  sin(double x);
///
pure float   sinf(float x);

///
pure double  tan(double x);
///
pure float   tanf(float x);

///
double  acosh(double x);
///
float   acoshf(float x);

///
pure double  asinh(double x);
///
pure float   asinhf(float x);

///
double  atanh(double x);
///
float   atanhf(float x);

///
double  cosh(double x);
///
float   coshf(float x);

///
double  sinh(double x);
///
float   sinhf(float x);

///
pure double  tanh(double x);
///
pure float   tanhf(float x);

///
double  exp(double x);
///
float   expf(float x);

///
double  exp2(double x);
///
float   exp2f(float x);

///
double  expm1(double x);
///
float   expm1f(float x);

///
pure double  frexp(double value, int* exp);
///
pure float   frexpf(float value, int* exp);

///
int     ilogb(double x);
///
int     ilogbf(float x);

///
double  ldexp(double x, int exp);
///
float   ldexpf(float x, int exp);

///
double  log(double x);
///
float   logf(float x);

///
double  log10(double x);
///
float   log10f(float x);

///
double  log1p(double x);
///
float   log1pf(float x);

///
double  log2(double x);
///
float   log2f(float x);

///
double  logb(double x);
///
float   logbf(float x);

///
pure double  modf(double value, double* iptr);
///
pure float   modff(float value, float* iptr);

///
double  scalbn(double x, int n);
///
float   scalbnf(float x, int n);

///
double  scalbln(double x, c_long n);
///
float   scalblnf(float x, c_long n);

///
pure double  cbrt(double x);
///
pure float   cbrtf(float x);

///
pure double  fabs(double x);

///
double  hypot(double x, double y);
///
float   hypotf(float x, float y);

///
double  pow(double x, double y);
///
float   powf(float x, float y);

///
double  sqrt(double x);
///
float   sqrtf(float x);

///
pure double  erf(double x);
///
pure float   erff(float x);

///
double  erfc(double x);
///
float   erfcf(float x);

///
double  lgamma(double x);
///
float   lgammaf(float x);

///
double  tgamma(double x);
///
float   tgammaf(float x);

///
pure double  ceil(double x);
///
pure float   ceilf(float x);

///
pure double  floor(double x);
///
pure float   floorf(float x);

///
pure double  nearbyint(double x);
///
pure float   nearbyintf(float x);

///
pure double  rint(double x);
///
pure float   rintf(float x);

///
c_long  lrint(double x);
///
c_long  lrintf(float x);

///
long    llrint(double x);
///
long    llrintf(float x);

///
pure double  round(double x);
///
pure float   roundf(float x);

///
c_long  lround(double x);
///
c_long  lroundf(float x);

///
long    llround(double x);
///
long    llroundf(float x);

///
pure double  trunc(double x);
///
pure float   truncf(float x);

///
double  fmod(double x, double y);
///
float   fmodf(float x, float y);

///
double  remainder(double x, double y);
///
float   remainderf(float x, float y);

///
double  remquo(double x, double y, int* quo);
///
float   remquof(float x, float y, int* quo);

///
pure double  copysign(double x, double y);
///
pure float   copysignf(float x, float y);

///
pure double  nan(char* tagp);
///
pure float   nanf(char* tagp);

///
double  nextafter(double x, double y);
///
float   nextafterf(float x, float y);
///

///
double  fdim(double x, double y);
///
float   fdimf(float x, float y);

///
pure double  fmax(double x, double y);
///
pure float   fmaxf(float x, float y);


///
pure double  fmin(double x, double y);
///
pure float   fminf(float x, float y);


///
pure double  fma(double x, double y, double z);
///
pure float   fmaf(float x, float y, float z);


///
real    acosl(real x);
///
real    asinl(real x);
///
pure real    atanl(real x);
///
real    atan2l(real y, real x);
///
pure real    cosl(real x);
///
pure real    sinl(real x);
///
pure real    tanl(real x);
///
real    acoshl(real x);
///
pure real    asinhl(real x);
///
real    atanhl(real x);
///
real    coshl(real x);
///
real    sinhl(real x);
///
pure real    tanhl(real x);
///
real    expl(real x);
///
real    exp2l(real x);
///
real    expm1l(real x);
///
pure real    frexpl(real value, int* exp);
///
int     ilogbl(real x);
///
real    ldexpl(real x, int exp);
///
real    logl(real x);
///
real    log10l(real x);
///
real    log1pl(real x);
///
real    log2l(real x);
///
real    logbl(real x);
///
pure real    modfl(real value, real *iptr);
///
real    scalbnl(real x, int n);
///
real    scalblnl(real x, c_long n);
///
pure real    cbrtl(real x);

///
pure float   fabsf(float x);
///
pure real    fabsl(real x);

///
real    hypotl(real x, real y);
///
real    powl(real x, real y);
///
real    sqrtl(real x);
///
pure real    erfl(real x);
///
real    erfcl(real x);
///
real    lgammal(real x);
///
real    tgammal(real x);
///
pure real    ceill(real x);
///
pure real    floorl(real x);
///
pure real    nearbyintl(real x);
///
pure real    rintl(real x);
///
c_long  lrintl(real x);
///
long    llrintl(real x);
///
pure real    roundl(real x);
///
c_long  lroundl(real x);
///
long    llroundl(real x);
///
pure real    truncl(real x);
///
real    fmodl(real x, real y);
///
real    remainderl(real x, real y);
///
real    remquol(real x, real y, int* quo);
///
pure real    copysignl(real x, real y);
///
pure real    nanl(char* tagp);
///
real    nextafterl(real x, real y);
///
double  nexttoward(double x, real y);
///
float   nexttowardf(float x, real y);
///
real    nexttowardl(real x, real y);
///
real    fdiml(real x, real y);
///
pure real    fmaxl(real x, real y);
///
pure real    fminl(real x, real y);
///
pure real    fmal(real x, real y, real z);
