//Written in the D programming language

/++
    Module containing core time functionality, such as $(LREF Duration) (which
    represents a duration of time) or $(LREF MonoTime) (which represents a
    timestamp of the system's monotonic clock).

    Various functions take a string (or strings) to represent a unit of time
    (e.g. $(D convert!("days", "hours")(numDays))). The valid strings to use
    with such functions are "years", "months", "weeks", "days", "hours",
    "minutes", "seconds", "msecs" (milliseconds), "usecs" (microseconds),
    "hnsecs" (hecto-nanoseconds - i.e. 100 ns) or some subset thereof. There
    are a few functions that also allow "nsecs", but very little actually
    has precision greater than hnsecs.

    $(BOOKTABLE Cheat Sheet,
    $(TR $(TH Symbol) $(TH Description))
    $(LEADINGROW Types)
    $(TR $(TDNW $(LREF Duration)) $(TD Represents a duration of time of weeks
    or less (kept internally as hnsecs). (e.g. 22 days or 700 seconds).))
    $(TR $(TDNW $(LREF MonoTime)) $(TD Represents a monotonic timestamp in
    system clock ticks, using the highest precision that the system provides.))
    $(LEADINGROW Functions)
    $(TR $(TDNW $(LREF convert)) $(TD Generic way of converting between two time
    units.))
    $(TR $(TDNW $(LREF dur)) $(TD Allows constructing a $(LREF Duration) from
    the given time units with the given length.))
    $(TR $(TDNW $(LREF weeks)$(NBSP)$(LREF days)$(NBSP)$(LREF hours)$(BR)
    $(LREF minutes)$(NBSP)$(LREF seconds)$(NBSP)$(LREF msecs)$(BR)
    $(LREF usecs)$(NBSP)$(LREF hnsecs)$(NBSP)$(LREF nsecs))
    $(TD Convenience aliases for $(LREF dur).))
    $(TR $(TDNW $(LREF abs)) $(TD Returns the absolute value of a duration.))
    )

    $(BOOKTABLE Conversions,
    $(TR $(TH )
     $(TH From $(LREF Duration))
     $(TH From units)
    )
    $(TR $(TD $(B To $(LREF Duration)))
     $(TD -)
     $(TD $(D dur!"msecs"(5)) or $(D 5.msecs()))
    )
    $(TR $(TD $(B To units))
     $(TD $(D duration.total!"days"))
     $(TD $(D convert!("days", "msecs")(msecs)))
    ))

    Copyright: Copyright 2010 - 2012
    License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:   $(HTTP jmdavisprog.com, Jonathan M Davis) and Kato Shoichi
    Source:    $(DRUNTIMESRC core/_time.d)
    Macros:
    NBSP=&nbsp;
 +/
module core.time;

import core.exception;
import core.internal.string;

version (WASIp1)
{
    import wasm_drt.wasip1 : Errno, Timestamp, clockResGet, clockTimeGet, ClockID;
}
else version (WASIp2)
{
    import monotonic_clock = wasm_drt.wasip2.clocks.monotonic_clock.imports;
}

version (unittest) import core.stdc.stdio : printf;

/++
    Represents a duration of time of weeks or less (kept internally as hnsecs).
    (e.g. 22 days or 700 seconds).

    It is used when representing a duration of time - such as how long to
    sleep with $(REF Thread.sleep, core,thread).

    In std.datetime, it is also used as the result of various arithmetic
    operations on time points.

    Use the $(LREF dur) function or one of its non-generic aliases to create
    $(D Duration)s.

    It's not possible to create a Duration of months or years, because the
    variable number of days in a month or year makes it impossible to convert
    between months or years and smaller units without a specific date. So,
    nothing uses $(D Duration)s when dealing with months or years. Rather,
    functions specific to months and years are defined. For instance,
    $(REF Date, std,datetime) has $(D add!"years") and $(D add!"months") for adding
    years and months rather than creating a Duration of years or months and
    adding that to a $(REF Date, std,datetime). But Duration is used when dealing
    with weeks or smaller.

    Examples:
--------------------
import std.datetime;

assert(dur!"days"(12) == dur!"hnsecs"(10_368_000_000_000L));
assert(dur!"hnsecs"(27) == dur!"hnsecs"(27));
assert(std.datetime.Date(2010, 9, 7) + dur!"days"(5) ==
       std.datetime.Date(2010, 9, 12));

assert(days(-12) == dur!"hnsecs"(-10_368_000_000_000L));
assert(hnsecs(-27) == dur!"hnsecs"(-27));
assert(std.datetime.Date(2010, 9, 7) - std.datetime.Date(2010, 10, 3) ==
       days(-26));
--------------------
 +/
struct Duration
{
    /++
        Converts this `Duration` to a `string`.

        The string is meant to be human readable, not machine parseable (e.g.
        whether there is an `'s'` on the end of the unit name usually depends on
        whether it's plural or not, and empty units are not included unless the
        Duration is `zero`). Any code needing a specific string format should
        use `total` or `split` to get the units needed to create the desired
        string format and create the string itself.

        The format returned by toString may or may not change in the future.

        Params:
          sink = A sink object, expected to be a delegate or aggregate
                 implementing `opCall` that accepts a `scope const(char)[]`
                 as argument.
      +/
    void toString (SinkT) (scope SinkT sink) const scope
    {
        static immutable units = [
            "weeks", "days", "hours", "minutes", "seconds", "msecs", "usecs"
        ];

        static void appListSep(SinkT sink, uint pos, bool last)
        {
            if (pos == 0)
                return;
            if (!last)
                sink(", ");
            else
                sink(pos == 1 ? " and " : ", and ");
        }

        static void appUnitVal(string units)(SinkT sink, long val)
        {
            immutable plural = val != 1;
            string unit;
            static if (units == "seconds")
                unit = plural ? "secs" : "sec";
            else static if (units == "msecs")
                unit = "ms";
            else static if (units == "usecs")
                unit = "μs";
            else
                unit = plural ? units : units[0 .. $-1];
            sink(signedToTempString(val));
            sink(" ");
            sink(unit);
        }

        if (_hnsecs == 0)
        {
            sink("0 hnsecs");
            return;
        }

        long hnsecs = _hnsecs;
        uint pos;
        static foreach (unit; units)
        {
            if (auto val = splitUnitsFromHNSecs!unit(hnsecs))
            {
                appListSep(sink, pos++, hnsecs == 0);
                appUnitVal!unit(sink, val);
            }
            if (hnsecs == 0)
                return;
        }
        if (hnsecs != 0)
        {
            appListSep(sink, pos++, true);
            appUnitVal!"hnsecs"(sink, hnsecs);
        }
    }

@safe pure:

public:

    /++
        A $(D Duration) of $(D 0). It's shorter than doing something like
        $(D dur!"seconds"(0)) and more explicit than $(D Duration.init).
      +/
    static @property nothrow @nogc Duration zero() { return Duration(0); }

    /++
        Largest $(D Duration) possible.
      +/
    static @property nothrow @nogc Duration max() { return Duration(long.max); }

    /++
        Most negative $(D Duration) possible.
      +/
    static @property nothrow @nogc Duration min() { return Duration(long.min); }

    version (CoreUnittest) unittest
    {
        assert(zero == dur!"seconds"(0));
        assert(Duration.max == Duration(long.max));
        assert(Duration.min == Duration(long.min));
        assert(Duration.min < Duration.zero);
        assert(Duration.zero < Duration.max);
        assert(Duration.min < Duration.max);
        assert(Duration.min - dur!"hnsecs"(1) == Duration.max);
        assert(Duration.max + dur!"hnsecs"(1) == Duration.min);
    }


    /++
        Compares this $(D Duration) with the given $(D Duration).

        Returns:
            $(TABLE
            $(TR $(TD this &lt; rhs) $(TD &lt; 0))
            $(TR $(TD this == rhs) $(TD 0))
            $(TR $(TD this &gt; rhs) $(TD &gt; 0))
            )
     +/
    int opCmp(Duration rhs) const nothrow @nogc
    {
        return (_hnsecs > rhs._hnsecs) - (_hnsecs < rhs._hnsecs);
    }

    version (CoreUnittest) unittest
    {
        import core.internal.traits : rvalueOf;
        foreach (T; AliasSeq!(Duration, const Duration, immutable Duration))
        {
            foreach (U; AliasSeq!(Duration, const Duration, immutable Duration))
            {
                T t = 42;
                // workaround https://issues.dlang.org/show_bug.cgi?id=18296
                version (D_Coverage)
                    U u = T(t._hnsecs);
                else
                    U u = t;
                assert(t == u);
                assert(rvalueOf(t) == u);
                assert(t == rvalueOf(u));
            }
        }

        foreach (D; AliasSeq!(Duration, const Duration, immutable Duration))
        {
            foreach (E; AliasSeq!(Duration, const Duration, immutable Duration))
            {
                assert((cast(D)Duration(12)).opCmp(cast(E)Duration(12)) == 0);
                assert((cast(D)Duration(-12)).opCmp(cast(E)Duration(-12)) == 0);

                assert((cast(D)Duration(10)).opCmp(cast(E)Duration(12)) < 0);
                assert((cast(D)Duration(-12)).opCmp(cast(E)Duration(12)) < 0);

                assert((cast(D)Duration(12)).opCmp(cast(E)Duration(10)) > 0);
                assert((cast(D)Duration(12)).opCmp(cast(E)Duration(-12)) > 0);

                assert(rvalueOf(cast(D)Duration(12)).opCmp(cast(E)Duration(12)) == 0);
                assert(rvalueOf(cast(D)Duration(-12)).opCmp(cast(E)Duration(-12)) == 0);

                assert(rvalueOf(cast(D)Duration(10)).opCmp(cast(E)Duration(12)) < 0);
                assert(rvalueOf(cast(D)Duration(-12)).opCmp(cast(E)Duration(12)) < 0);

                assert(rvalueOf(cast(D)Duration(12)).opCmp(cast(E)Duration(10)) > 0);
                assert(rvalueOf(cast(D)Duration(12)).opCmp(cast(E)Duration(-12)) > 0);

                assert((cast(D)Duration(12)).opCmp(rvalueOf(cast(E)Duration(12))) == 0);
                assert((cast(D)Duration(-12)).opCmp(rvalueOf(cast(E)Duration(-12))) == 0);

                assert((cast(D)Duration(10)).opCmp(rvalueOf(cast(E)Duration(12))) < 0);
                assert((cast(D)Duration(-12)).opCmp(rvalueOf(cast(E)Duration(12))) < 0);

                assert((cast(D)Duration(12)).opCmp(rvalueOf(cast(E)Duration(10))) > 0);
                assert((cast(D)Duration(12)).opCmp(rvalueOf(cast(E)Duration(-12))) > 0);
            }
        }
    }


    /++
        Adds, subtracts or calculates the modulo of two durations.

        The legal types of arithmetic for $(D Duration) using this operator are

        $(TABLE
        $(TR $(TD Duration) $(TD +) $(TD Duration) $(TD -->) $(TD Duration))
        $(TR $(TD Duration) $(TD -) $(TD Duration) $(TD -->) $(TD Duration))
        $(TR $(TD Duration) $(TD %) $(TD Duration) $(TD -->) $(TD Duration))
        )

        Params:
            rhs = The duration to add to or subtract from this $(D Duration).
      +/
    Duration opBinary(string op)(const Duration rhs) const nothrow @nogc
        if (op == "+" || op == "-" || op == "%")
    {
        return Duration(mixin("_hnsecs " ~ op ~ " rhs._hnsecs"));
    }

    version (CoreUnittest) unittest
    {
        alias Types = AliasSeq!(Duration, const Duration, immutable Duration);
        foreach (D; Types)
        {
            foreach (E; Types)
            {
                assert((cast(D)Duration(5)) + (cast(E)Duration(7)) == Duration(12));
                assert((cast(D)Duration(5)) - (cast(E)Duration(7)) == Duration(-2));
                assert((cast(D)Duration(5)) % (cast(E)Duration(7)) == Duration(5));
                assert((cast(D)Duration(7)) + (cast(E)Duration(5)) == Duration(12));
                assert((cast(D)Duration(7)) - (cast(E)Duration(5)) == Duration(2));
                assert((cast(D)Duration(7)) % (cast(E)Duration(5)) == Duration(2));

                assert((cast(D)Duration(5)) + (cast(E)Duration(-7)) == Duration(-2));
                assert((cast(D)Duration(5)) - (cast(E)Duration(-7)) == Duration(12));
                assert((cast(D)Duration(5)) % (cast(E)Duration(-7)) == Duration(5));
                assert((cast(D)Duration(7)) + (cast(E)Duration(-5)) == Duration(2));
                assert((cast(D)Duration(7)) - (cast(E)Duration(-5)) == Duration(12));
                assert((cast(D)Duration(7)) % (cast(E)Duration(-5)) == Duration(2));

                assert((cast(D)Duration(-5)) + (cast(E)Duration(7)) == Duration(2));
                assert((cast(D)Duration(-5)) - (cast(E)Duration(7)) == Duration(-12));
                assert((cast(D)Duration(-5)) % (cast(E)Duration(7)) == Duration(-5));
                assert((cast(D)Duration(-7)) + (cast(E)Duration(5)) == Duration(-2));
                assert((cast(D)Duration(-7)) - (cast(E)Duration(5)) == Duration(-12));
                assert((cast(D)Duration(-7)) % (cast(E)Duration(5)) == Duration(-2));

                assert((cast(D)Duration(-5)) + (cast(E)Duration(-7)) == Duration(-12));
                assert((cast(D)Duration(-5)) - (cast(E)Duration(-7)) == Duration(2));
                assert((cast(D)Duration(-5)) % (cast(E)Duration(7)) == Duration(-5));
                assert((cast(D)Duration(-7)) + (cast(E)Duration(-5)) == Duration(-12));
                assert((cast(D)Duration(-7)) - (cast(E)Duration(-5)) == Duration(-2));
                assert((cast(D)Duration(-7)) % (cast(E)Duration(5)) == Duration(-2));
            }
        }
    }

    /++
        Adds, subtracts or calculates the modulo of two durations as well as
        assigning the result to this $(D Duration).

        The legal types of arithmetic for $(D Duration) using this operator are

        $(TABLE
        $(TR $(TD Duration) $(TD +) $(TD Duration) $(TD -->) $(TD Duration))
        $(TR $(TD Duration) $(TD -) $(TD Duration) $(TD -->) $(TD Duration))
        $(TR $(TD Duration) $(TD %) $(TD Duration) $(TD -->) $(TD Duration))
        )

        Params:
            rhs = The duration to add to or subtract from this $(D Duration).
      +/
    ref Duration opOpAssign(string op)(const Duration rhs) nothrow @nogc
        if (op == "+" || op == "-" || op == "%")
    {
        mixin("_hnsecs " ~ op ~ "= rhs._hnsecs;");
        return this;
    }

    version (CoreUnittest) unittest
    {
        static void test1(string op, E)(Duration actual, in E rhs, Duration expected, size_t line = __LINE__)
        {
            if (mixin("actual " ~ op ~ " rhs") != expected)
                throw new AssertError("op failed", __FILE__, line);

            if (actual != expected)
                throw new AssertError("op assign failed", __FILE__, line);
        }

        foreach (E; AliasSeq!(Duration, const Duration, immutable Duration))
        {
            test1!"+="(Duration(5), (cast(E)Duration(7)), Duration(12));
            test1!"-="(Duration(5), (cast(E)Duration(7)), Duration(-2));
            test1!"%="(Duration(5), (cast(E)Duration(7)), Duration(5));
            test1!"+="(Duration(7), (cast(E)Duration(5)), Duration(12));
            test1!"-="(Duration(7), (cast(E)Duration(5)), Duration(2));
            test1!"%="(Duration(7), (cast(E)Duration(5)), Duration(2));

            test1!"+="(Duration(5), (cast(E)Duration(-7)), Duration(-2));
            test1!"-="(Duration(5), (cast(E)Duration(-7)), Duration(12));
            test1!"%="(Duration(5), (cast(E)Duration(-7)), Duration(5));
            test1!"+="(Duration(7), (cast(E)Duration(-5)), Duration(2));
            test1!"-="(Duration(7), (cast(E)Duration(-5)), Duration(12));
            test1!"%="(Duration(7), (cast(E)Duration(-5)), Duration(2));

            test1!"+="(Duration(-5), (cast(E)Duration(7)), Duration(2));
            test1!"-="(Duration(-5), (cast(E)Duration(7)), Duration(-12));
            test1!"%="(Duration(-5), (cast(E)Duration(7)), Duration(-5));
            test1!"+="(Duration(-7), (cast(E)Duration(5)), Duration(-2));
            test1!"-="(Duration(-7), (cast(E)Duration(5)), Duration(-12));
            test1!"%="(Duration(-7), (cast(E)Duration(5)), Duration(-2));

            test1!"+="(Duration(-5), (cast(E)Duration(-7)), Duration(-12));
            test1!"-="(Duration(-5), (cast(E)Duration(-7)), Duration(2));
            test1!"%="(Duration(-5), (cast(E)Duration(-7)), Duration(-5));
            test1!"+="(Duration(-7), (cast(E)Duration(-5)), Duration(-12));
            test1!"-="(Duration(-7), (cast(E)Duration(-5)), Duration(-2));
            test1!"%="(Duration(-7), (cast(E)Duration(-5)), Duration(-2));
        }

        foreach (D; AliasSeq!(const Duration, immutable Duration))
        {
            foreach (E; AliasSeq!(Duration, const Duration, immutable Duration))
            {
                D lhs = D(120);
                E rhs = E(120);
                static assert(!__traits(compiles, lhs += rhs), D.stringof ~ " " ~ E.stringof);
            }
        }
    }

    /++
        Multiplies or divides the duration by an integer value.

        The legal types of arithmetic for $(D Duration) using this operator
        overload are

        $(TABLE
        $(TR $(TD Duration) $(TD *) $(TD long) $(TD -->) $(TD Duration))
        $(TR $(TD Duration) $(TD /) $(TD long) $(TD -->) $(TD Duration))
        )

        Params:
            value = The value to multiply this $(D Duration) by.
      +/
    Duration opBinary(string op)(long value) const nothrow @nogc
        if (op == "*" || op == "/")
    {
        mixin("return Duration(_hnsecs " ~ op ~ " value);");
    }

    version (CoreUnittest) unittest
    {
        foreach (D; AliasSeq!(Duration, const Duration, immutable Duration))
        {
            assert((cast(D)Duration(5)) * 7 == Duration(35));
            assert((cast(D)Duration(7)) * 5 == Duration(35));

            assert((cast(D)Duration(5)) * -7 == Duration(-35));
            assert((cast(D)Duration(7)) * -5 == Duration(-35));

            assert((cast(D)Duration(-5)) * 7 == Duration(-35));
            assert((cast(D)Duration(-7)) * 5 == Duration(-35));

            assert((cast(D)Duration(-5)) * -7 == Duration(35));
            assert((cast(D)Duration(-7)) * -5 == Duration(35));

            assert((cast(D)Duration(5)) * 0 == Duration(0));
            assert((cast(D)Duration(-5)) * 0 == Duration(0));
        }
    }

    version (CoreUnittest) unittest
    {
        foreach (D; AliasSeq!(Duration, const Duration, immutable Duration))
        {
            assert((cast(D)Duration(5)) / 7 == Duration(0));
            assert((cast(D)Duration(7)) / 5 == Duration(1));

            assert((cast(D)Duration(5)) / -7 == Duration(0));
            assert((cast(D)Duration(7)) / -5 == Duration(-1));

            assert((cast(D)Duration(-5)) / 7 == Duration(0));
            assert((cast(D)Duration(-7)) / 5 == Duration(-1));

            assert((cast(D)Duration(-5)) / -7 == Duration(0));
            assert((cast(D)Duration(-7)) / -5 == Duration(1));
        }
    }


    /++
        Multiplies/Divides the duration by an integer value as well as
        assigning the result to this $(D Duration).

        The legal types of arithmetic for $(D Duration) using this operator
        overload are

        $(TABLE
        $(TR $(TD Duration) $(TD *) $(TD long) $(TD -->) $(TD Duration))
        $(TR $(TD Duration) $(TD /) $(TD long) $(TD -->) $(TD Duration))
        )

        Params:
            value = The value to multiply/divide this $(D Duration) by.
      +/
    ref Duration opOpAssign(string op)(long value) nothrow @nogc
        if (op == "*" || op == "/")
    {
        mixin("_hnsecs " ~ op ~ "= value;");
        return this;
    }

    version (CoreUnittest) unittest
    {
        static void test(D)(D actual, long value, Duration expected, size_t line = __LINE__)
        {
            if ((actual *= value) != expected)
                throw new AssertError("op failed", __FILE__, line);

            if (actual != expected)
                throw new AssertError("op assign failed", __FILE__, line);
        }

        test(Duration(5), 7, Duration(35));
        test(Duration(7), 5, Duration(35));

        test(Duration(5), -7, Duration(-35));
        test(Duration(7), -5, Duration(-35));

        test(Duration(-5), 7, Duration(-35));
        test(Duration(-7), 5, Duration(-35));

        test(Duration(-5), -7, Duration(35));
        test(Duration(-7), -5, Duration(35));

        test(Duration(5), 0, Duration(0));
        test(Duration(-5), 0, Duration(0));

        const cdur = Duration(12);
        immutable idur = Duration(12);
        static assert(!__traits(compiles, cdur *= 12));
        static assert(!__traits(compiles, idur *= 12));
    }

    version (CoreUnittest) unittest
    {
        static void test(Duration actual, long value, Duration expected, size_t line = __LINE__)
        {
            if ((actual /= value) != expected)
                throw new AssertError("op failed", __FILE__, line);

            if (actual != expected)
                throw new AssertError("op assign failed", __FILE__, line);
        }

        test(Duration(5), 7, Duration(0));
        test(Duration(7), 5, Duration(1));

        test(Duration(5), -7, Duration(0));
        test(Duration(7), -5, Duration(-1));

        test(Duration(-5), 7, Duration(0));
        test(Duration(-7), 5, Duration(-1));

        test(Duration(-5), -7, Duration(0));
        test(Duration(-7), -5, Duration(1));

        const cdur = Duration(12);
        immutable idur = Duration(12);
        static assert(!__traits(compiles, cdur /= 12));
        static assert(!__traits(compiles, idur /= 12));
    }


    /++
        Divides two durations.

        The legal types of arithmetic for $(D Duration) using this operator are

        $(TABLE
        $(TR $(TD Duration) $(TD /) $(TD Duration) $(TD -->) $(TD long))
        )

        Params:
            rhs = The duration to divide this $(D Duration) by.
      +/
    long opBinary(string op)(Duration rhs) const nothrow @nogc
        if (op == "/")
    {
        return _hnsecs / rhs._hnsecs;
    }

    version (CoreUnittest) unittest
    {
        assert(Duration(5) / Duration(7) == 0);
        assert(Duration(7) / Duration(5) == 1);
        assert(Duration(8) / Duration(4) == 2);

        assert(Duration(5) / Duration(-7) == 0);
        assert(Duration(7) / Duration(-5) == -1);
        assert(Duration(8) / Duration(-4) == -2);

        assert(Duration(-5) / Duration(7) == 0);
        assert(Duration(-7) / Duration(5) == -1);
        assert(Duration(-8) / Duration(4) == -2);

        assert(Duration(-5) / Duration(-7) == 0);
        assert(Duration(-7) / Duration(-5) == 1);
        assert(Duration(-8) / Duration(-4) == 2);
    }


    /++
        Multiplies an integral value and a $(D Duration).

        The legal types of arithmetic for $(D Duration) using this operator
        overload are

        $(TABLE
        $(TR $(TD long) $(TD *) $(TD Duration) $(TD -->) $(TD Duration))
        )

        Params:
            value = The number of units to multiply this $(D Duration) by.
      +/
    Duration opBinaryRight(string op)(long value) const nothrow @nogc
        if (op == "*")
    {
        return opBinary!op(value);
    }

    version (CoreUnittest) unittest
    {
        foreach (D; AliasSeq!(Duration, const Duration, immutable Duration))
        {
            assert(5 * cast(D)Duration(7) == Duration(35));
            assert(7 * cast(D)Duration(5) == Duration(35));

            assert(5 * cast(D)Duration(-7) == Duration(-35));
            assert(7 * cast(D)Duration(-5) == Duration(-35));

            assert(-5 * cast(D)Duration(7) == Duration(-35));
            assert(-7 * cast(D)Duration(5) == Duration(-35));

            assert(-5 * cast(D)Duration(-7) == Duration(35));
            assert(-7 * cast(D)Duration(-5) == Duration(35));

            assert(0 * cast(D)Duration(-5) == Duration(0));
            assert(0 * cast(D)Duration(5) == Duration(0));
        }
    }


    /++
        Returns the negation of this $(D Duration).
      +/
    Duration opUnary(string op)() const nothrow @nogc
        if (op == "-")
    {
        return Duration(-_hnsecs);
    }

    version (CoreUnittest) unittest
    {
        foreach (D; AliasSeq!(Duration, const Duration, immutable Duration))
        {
            assert(-(cast(D)Duration(7)) == Duration(-7));
            assert(-(cast(D)Duration(5)) == Duration(-5));
            assert(-(cast(D)Duration(-7)) == Duration(7));
            assert(-(cast(D)Duration(-5)) == Duration(5));
            assert(-(cast(D)Duration(0)) == Duration(0));
        }
    }

    /++
        Allow Duration to be used as a boolean.
        Returns: `true` if this duration is non-zero.
      +/
    bool opCast(T : bool)() const nothrow @nogc
    {
        return _hnsecs != 0;
    }

    version (CoreUnittest) unittest
    {
        auto d = 10.minutes;
        assert(d);
        assert(!(d - d));
        assert(d + d);
    }

    //Temporary hack until bug http://d.puremagic.com/issues/show_bug.cgi?id=5747 is fixed.
    Duration opCast(T)() const nothrow @nogc
        if (is(immutable T == immutable Duration))
    {
        return this;
    }


    /++
        Splits out the Duration into the given units.

        split takes the list of time units to split out as template arguments.
        The time unit strings must be given in decreasing order. How it returns
        the values for those units depends on the overload used.

        The overload which accepts function arguments takes integral types in
        the order that the time unit strings were given, and those integers are
        passed by $(D ref). split assigns the values for the units to each
        corresponding integer. Any integral type may be used, but no attempt is
        made to prevent integer overflow, so don't use small integral types in
        circumstances where the values for those units aren't likely to fit in
        an integral type that small.

        The overload with no arguments returns the values for the units in a
        struct with members whose names are the same as the given time unit
        strings. The members are all $(D long)s. This overload will also work
        with no time strings being given, in which case $(I all) of the time
        units from weeks through hnsecs will be provided (but no nsecs, since it
        would always be $(D 0)).

        For both overloads, the entire value of the Duration is split among the
        units (rather than splitting the Duration across all units and then only
        providing the values for the requested units), so if only one unit is
        given, the result is equivalent to $(LREF total).

        $(D "nsecs") is accepted by split, but $(D "years") and $(D "months")
        are not.

        For negative durations, all of the split values will be negative.
      +/
    template split(units...)
        if (allAreAcceptedUnits!("weeks", "days", "hours", "minutes", "seconds",
                                "msecs", "usecs", "hnsecs", "nsecs")([units]) &&
           unitsAreInDescendingOrder([units]))
    {
        /++ Ditto +/
        void split(Args...)(out Args args) const nothrow @nogc
            if (units.length != 0 && args.length == units.length && allAreMutableIntegralTypes!Args)
        {
            long hnsecs = _hnsecs;
            foreach (i, unit; units)
            {
                static if (unit == "nsecs")
                    args[i] = cast(Args[i])convert!("hnsecs", "nsecs")(hnsecs);
                else
                    args[i] = cast(Args[i])splitUnitsFromHNSecs!unit(hnsecs);
            }
        }

        /++ Ditto +/
        auto split() const nothrow @nogc
        {
            static if (units.length == 0)
                return split!("weeks", "days", "hours", "minutes", "seconds", "msecs", "usecs", "hnsecs")();
            else
            {
                static string genMemberDecls()
                {
                    string retval;
                    foreach (unit; units)
                    {
                        retval ~= "long ";
                        retval ~= unit;
                        retval ~= "; ";
                    }
                    return retval;
                }

                static struct SplitUnits
                {
                    mixin(genMemberDecls());
                }

                static string genSplitCall()
                {
                    auto retval = "split(";
                    foreach (i, unit; units)
                    {
                        retval ~= "su.";
                        retval ~= unit;
                        if (i < units.length - 1)
                            retval ~= ", ";
                        else
                            retval ~= ");";
                    }
                    return retval;
                }

                SplitUnits su = void;
                mixin(genSplitCall());
                return su;
            }
        }

        /+
            Whether all of the given arguments are integral types.
          +/
        private template allAreMutableIntegralTypes(Args...)
        {
            static if (Args.length == 0)
                enum allAreMutableIntegralTypes = true;
            else static if (!is(Args[0] == long) &&
                           !is(Args[0] == int) &&
                           !is(Args[0] == short) &&
                           !is(Args[0] == byte) &&
                           !is(Args[0] == ulong) &&
                           !is(Args[0] == uint) &&
                           !is(Args[0] == ushort) &&
                           !is(Args[0] == ubyte))
            {
                enum allAreMutableIntegralTypes = false;
            }
            else
                enum allAreMutableIntegralTypes = allAreMutableIntegralTypes!(Args[1 .. $]);
        }

        version (CoreUnittest) unittest
        {
            foreach (T; AliasSeq!(long, int, short, byte, ulong, uint, ushort, ubyte))
                static assert(allAreMutableIntegralTypes!T);
            foreach (T; AliasSeq!(long, int, short, byte, ulong, uint, ushort, ubyte))
                static assert(!allAreMutableIntegralTypes!(const T));
            foreach (T; AliasSeq!(char, wchar, dchar, float, double, real, string))
                static assert(!allAreMutableIntegralTypes!T);
            static assert(allAreMutableIntegralTypes!(long, int, short, byte));
            static assert(!allAreMutableIntegralTypes!(long, int, short, char, byte));
            static assert(!allAreMutableIntegralTypes!(long, int*, short));
        }
    }

    ///
    unittest
    {
        {
            auto d = dur!"days"(12) + dur!"minutes"(7) + dur!"usecs"(501223);
            long days;
            int seconds;
            short msecs;
            d.split!("days", "seconds", "msecs")(days, seconds, msecs);
            assert(days == 12);
            assert(seconds == 7 * 60);
            assert(msecs == 501);

            auto splitStruct = d.split!("days", "seconds", "msecs")();
            assert(splitStruct.days == 12);
            assert(splitStruct.seconds == 7 * 60);
            assert(splitStruct.msecs == 501);

            auto fullSplitStruct = d.split();
            assert(fullSplitStruct.weeks == 1);
            assert(fullSplitStruct.days == 5);
            assert(fullSplitStruct.hours == 0);
            assert(fullSplitStruct.minutes == 7);
            assert(fullSplitStruct.seconds == 0);
            assert(fullSplitStruct.msecs == 501);
            assert(fullSplitStruct.usecs == 223);
            assert(fullSplitStruct.hnsecs == 0);

            assert(d.split!"minutes"().minutes == d.total!"minutes");
        }

        {
            auto d = dur!"days"(12);
            assert(d.split!"weeks"().weeks == 1);
            assert(d.split!"days"().days == 12);

            assert(d.split().weeks == 1);
            assert(d.split().days == 5);
        }

        {
            auto d = dur!"days"(7) + dur!"hnsecs"(42);
            assert(d.split!("seconds", "nsecs")().nsecs == 4200);
        }

        {
            auto d = dur!"days"(-7) + dur!"hours"(-9);
            auto result = d.split!("days", "hours")();
            assert(result.days == -7);
            assert(result.hours == -9);
        }
    }

    version (CoreUnittest) pure nothrow unittest
    {
        foreach (D; AliasSeq!(const Duration, immutable Duration))
        {
            D d = dur!"weeks"(3) + dur!"days"(5) + dur!"hours"(19) + dur!"minutes"(7) +
                  dur!"seconds"(2) + dur!"hnsecs"(1234567);
            byte weeks;
            ubyte days;
            short hours;
            ushort minutes;
            int seconds;
            uint msecs;
            long usecs;
            ulong hnsecs;
            long nsecs;

            d.split!("weeks", "days", "hours", "minutes", "seconds", "msecs", "usecs", "hnsecs", "nsecs")
                    (weeks, days, hours, minutes, seconds, msecs, usecs, hnsecs, nsecs);
            assert(weeks == 3);
            assert(days == 5);
            assert(hours == 19);
            assert(minutes == 7);
            assert(seconds == 2);
            assert(msecs == 123);
            assert(usecs == 456);
            assert(hnsecs == 7);
            assert(nsecs == 0);

            d.split!("weeks", "days", "hours", "seconds", "usecs")(weeks, days, hours, seconds, usecs);
            assert(weeks == 3);
            assert(days == 5);
            assert(hours == 19);
            assert(seconds == 422);
            assert(usecs == 123456);

            d.split!("days", "minutes", "seconds", "nsecs")(days, minutes, seconds, nsecs);
            assert(days == 26);
            assert(minutes == 1147);
            assert(seconds == 2);
            assert(nsecs == 123456700);

            d.split!("minutes", "msecs", "usecs", "hnsecs")(minutes, msecs, usecs, hnsecs);
            assert(minutes == 38587);
            assert(msecs == 2123);
            assert(usecs == 456);
            assert(hnsecs == 7);

            {
                auto result = d.split!("weeks", "days", "hours", "minutes", "seconds",
                                       "msecs", "usecs", "hnsecs", "nsecs");
                assert(result.weeks == 3);
                assert(result.days == 5);
                assert(result.hours == 19);
                assert(result.minutes == 7);
                assert(result.seconds == 2);
                assert(result.msecs == 123);
                assert(result.usecs == 456);
                assert(result.hnsecs == 7);
                assert(result.nsecs == 0);
            }

            {
                auto result = d.split!("weeks", "days", "hours", "seconds", "usecs");
                assert(result.weeks == 3);
                assert(result.days == 5);
                assert(result.hours == 19);
                assert(result.seconds == 422);
                assert(result.usecs == 123456);
            }

            {
                auto result = d.split!("days", "minutes", "seconds", "nsecs")();
                assert(result.days == 26);
                assert(result.minutes == 1147);
                assert(result.seconds == 2);
                assert(result.nsecs == 123456700);
            }

            {
                auto result = d.split!("minutes", "msecs", "usecs", "hnsecs")();
                assert(result.minutes == 38587);
                assert(result.msecs == 2123);
                assert(result.usecs == 456);
                assert(result.hnsecs == 7);
            }

            {
                auto result = d.split();
                assert(result.weeks == 3);
                assert(result.days == 5);
                assert(result.hours == 19);
                assert(result.minutes == 7);
                assert(result.seconds == 2);
                assert(result.msecs == 123);
                assert(result.usecs == 456);
                assert(result.hnsecs == 7);
                static assert(!is(typeof(result.nsecs)));
            }

            static assert(!is(typeof(d.split("seconds", "hnsecs")(seconds))));
            static assert(!is(typeof(d.split("hnsecs", "seconds", "minutes")(hnsecs, seconds, minutes))));
            static assert(!is(typeof(d.split("hnsecs", "seconds", "msecs")(hnsecs, seconds, msecs))));
            static assert(!is(typeof(d.split("seconds", "hnecs", "msecs")(seconds, hnsecs, msecs))));
            static assert(!is(typeof(d.split("seconds", "msecs", "msecs")(seconds, msecs, msecs))));
            static assert(!is(typeof(d.split("hnsecs", "seconds", "minutes")())));
            static assert(!is(typeof(d.split("hnsecs", "seconds", "msecs")())));
            static assert(!is(typeof(d.split("seconds", "hnecs", "msecs")())));
            static assert(!is(typeof(d.split("seconds", "msecs", "msecs")())));
            alias timeStrs = AliasSeq!("nsecs", "hnsecs", "usecs", "msecs", "seconds",
                              "minutes", "hours", "days", "weeks");
            foreach (i, str; timeStrs[1 .. $])
                static assert(!is(typeof(d.split!(timeStrs[i - 1], str)())));

            D nd = -d;

            {
                auto result = nd.split();
                assert(result.weeks == -3);
                assert(result.days == -5);
                assert(result.hours == -19);
                assert(result.minutes == -7);
                assert(result.seconds == -2);
                assert(result.msecs == -123);
                assert(result.usecs == -456);
                assert(result.hnsecs == -7);
            }

            {
                auto result = nd.split!("weeks", "days", "hours", "minutes", "seconds", "nsecs")();
                assert(result.weeks == -3);
                assert(result.days == -5);
                assert(result.hours == -19);
                assert(result.minutes == -7);
                assert(result.seconds == -2);
                assert(result.nsecs == -123456700);
            }
        }
    }


    /++
        Returns the total number of the given units in this $(D Duration).
        So, unlike $(D split), it does not strip out the larger units.
      +/
    @property long total(string units)() const nothrow @nogc
        if (units == "weeks" ||
           units == "days" ||
           units == "hours" ||
           units == "minutes" ||
           units == "seconds" ||
           units == "msecs" ||
           units == "usecs" ||
           units == "hnsecs" ||
           units == "nsecs")
    {
        return convert!("hnsecs", units)(_hnsecs);
    }

    ///
    unittest
    {
        assert(dur!"weeks"(12).total!"weeks" == 12);
        assert(dur!"weeks"(12).total!"days" == 84);

        assert(dur!"days"(13).total!"weeks" == 1);
        assert(dur!"days"(13).total!"days" == 13);

        assert(dur!"hours"(49).total!"days" == 2);
        assert(dur!"hours"(49).total!"hours" == 49);

        assert(dur!"nsecs"(2007).total!"hnsecs" == 20);
        assert(dur!"nsecs"(2007).total!"nsecs" == 2000);
    }

    version (CoreUnittest) unittest
    {
        foreach (D; AliasSeq!(const Duration, immutable Duration))
        {
            assert((cast(D)dur!"weeks"(12)).total!"weeks" == 12);
            assert((cast(D)dur!"weeks"(12)).total!"days" == 84);

            assert((cast(D)dur!"days"(13)).total!"weeks" == 1);
            assert((cast(D)dur!"days"(13)).total!"days" == 13);

            assert((cast(D)dur!"hours"(49)).total!"days" == 2);
            assert((cast(D)dur!"hours"(49)).total!"hours" == 49);

            assert((cast(D)dur!"nsecs"(2007)).total!"hnsecs" == 20);
            assert((cast(D)dur!"nsecs"(2007)).total!"nsecs" == 2000);
        }
    }

    /// Ditto
    string toString() const scope nothrow
    {
        string result;
        this.toString((in char[] data) { result ~= data; });
        return result;
    }

    ///
    unittest
    {
        assert(Duration.zero.toString() == "0 hnsecs");
        assert(weeks(5).toString() == "5 weeks");
        assert(days(2).toString() == "2 days");
        assert(hours(1).toString() == "1 hour");
        assert(minutes(19).toString() == "19 minutes");
        assert(seconds(42).toString() == "42 secs");
        assert(msecs(42).toString() == "42 ms");
        assert(usecs(27).toString() == "27 μs");
        assert(hnsecs(5).toString() == "5 hnsecs");

        assert(seconds(121).toString() == "2 minutes and 1 sec");
        assert((minutes(5) + seconds(3) + usecs(4)).toString() ==
               "5 minutes, 3 secs, and 4 μs");

        assert(seconds(-42).toString() == "-42 secs");
        assert(usecs(-5239492).toString() == "-5 secs, -239 ms, and -492 μs");
    }

    version (CoreUnittest) unittest
    {
        foreach (D; AliasSeq!(Duration, const Duration, immutable Duration))
        {
            assert((cast(D)Duration(0)).toString() == "0 hnsecs");
            assert((cast(D)Duration(1)).toString() == "1 hnsec");
            assert((cast(D)Duration(7)).toString() == "7 hnsecs");
            assert((cast(D)Duration(10)).toString() == "1 μs");
            assert((cast(D)Duration(20)).toString() == "2 μs");
            assert((cast(D)Duration(10_000)).toString() == "1 ms");
            assert((cast(D)Duration(20_000)).toString() == "2 ms");
            assert((cast(D)Duration(10_000_000)).toString() == "1 sec");
            assert((cast(D)Duration(20_000_000)).toString() == "2 secs");
            assert((cast(D)Duration(600_000_000)).toString() == "1 minute");
            assert((cast(D)Duration(1_200_000_000)).toString() == "2 minutes");
            assert((cast(D)Duration(36_000_000_000)).toString() == "1 hour");
            assert((cast(D)Duration(72_000_000_000)).toString() == "2 hours");
            assert((cast(D)Duration(864_000_000_000)).toString() == "1 day");
            assert((cast(D)Duration(1_728_000_000_000)).toString() == "2 days");
            assert((cast(D)Duration(6_048_000_000_000)).toString() == "1 week");
            assert((cast(D)Duration(12_096_000_000_000)).toString() == "2 weeks");

            assert((cast(D)Duration(12)).toString() == "1 μs and 2 hnsecs");
            assert((cast(D)Duration(120_795)).toString() == "12 ms, 79 μs, and 5 hnsecs");
            assert((cast(D)Duration(12_096_020_900_003)).toString() == "2 weeks, 2 secs, 90 ms, and 3 hnsecs");

            assert((cast(D)Duration(-1)).toString() == "-1 hnsecs");
            assert((cast(D)Duration(-7)).toString() == "-7 hnsecs");
            assert((cast(D)Duration(-10)).toString() == "-1 μs");
            assert((cast(D)Duration(-20)).toString() == "-2 μs");
            assert((cast(D)Duration(-10_000)).toString() == "-1 ms");
            assert((cast(D)Duration(-20_000)).toString() == "-2 ms");
            assert((cast(D)Duration(-10_000_000)).toString() == "-1 secs");
            assert((cast(D)Duration(-20_000_000)).toString() == "-2 secs");
            assert((cast(D)Duration(-600_000_000)).toString() == "-1 minutes");
            assert((cast(D)Duration(-1_200_000_000)).toString() == "-2 minutes");
            assert((cast(D)Duration(-36_000_000_000)).toString() == "-1 hours");
            assert((cast(D)Duration(-72_000_000_000)).toString() == "-2 hours");
            assert((cast(D)Duration(-864_000_000_000)).toString() == "-1 days");
            assert((cast(D)Duration(-1_728_000_000_000)).toString() == "-2 days");
            assert((cast(D)Duration(-6_048_000_000_000)).toString() == "-1 weeks");
            assert((cast(D)Duration(-12_096_000_000_000)).toString() == "-2 weeks");

            assert((cast(D)Duration(-12)).toString() == "-1 μs and -2 hnsecs");
            assert((cast(D)Duration(-120_795)).toString() == "-12 ms, -79 μs, and -5 hnsecs");
            assert((cast(D)Duration(-12_096_020_900_003)).toString() == "-2 weeks, -2 secs, -90 ms, and -3 hnsecs");
        }
    }


    /++
        Returns whether this $(D Duration) is negative.
      +/
    @property bool isNegative() const nothrow @nogc
    {
        return _hnsecs < 0;
    }

    version (CoreUnittest) unittest
    {
        foreach (D; AliasSeq!(Duration, const Duration, immutable Duration))
        {
            assert(!(cast(D)Duration(100)).isNegative);
            assert(!(cast(D)Duration(1)).isNegative);
            assert(!(cast(D)Duration(0)).isNegative);
            assert((cast(D)Duration(-1)).isNegative);
            assert((cast(D)Duration(-100)).isNegative);
        }
    }


private:

    /+
        Params:
            hnsecs = The total number of hecto-nanoseconds in this $(D Duration).
      +/
    this(long hnsecs) nothrow @nogc
    {
        _hnsecs = hnsecs;
    }


    long _hnsecs;
}

///
unittest
{
    import core.time;

    // using the dur template
    auto numDays = dur!"days"(12);

    // using the days function
    numDays = days(12);

    // alternatively using UFCS syntax
    numDays = 12.days;

    auto myTime = 100.msecs + 20_000.usecs + 30_000.hnsecs;
    assert(myTime == 123.msecs);
}

// Ensure `toString` doesn't allocate if the sink doesn't
version (CoreUnittest) @safe pure nothrow @nogc unittest
{
    char[256] buffer; size_t len;
    scope sink = (in char[] data) {
        assert(data.length + len <= buffer.length);
        buffer[len .. len + data.length] = data[];
        len += data.length;
    };
    auto dur = Duration(-12_096_020_900_003);
    dur.toString(sink);
    assert(buffer[0 .. len] == "-2 weeks, -2 secs, -90 ms, and -3 hnsecs");
}

/++
    These allow you to construct a $(D Duration) from the given time units
    with the given length.

    You can either use the generic function $(D dur) and give it the units as
    a $(D string) or use the named aliases.

    The possible values for units are $(D "weeks"), $(D "days"), $(D "hours"),
    $(D "minutes"), $(D "seconds"), $(D "msecs") (milliseconds), $(D "usecs"),
    (microseconds), $(D "hnsecs") (hecto-nanoseconds, i.e. 100 ns), and
    $(D "nsecs").

    Params:
        units  = The time units of the $(D Duration) (e.g. $(D "days")).
        length = The number of units in the $(D Duration).
  +/
Duration dur(string units)(long length) @safe pure nothrow @nogc
    if (units == "weeks" ||
       units == "days" ||
       units == "hours" ||
       units == "minutes" ||
       units == "seconds" ||
       units == "msecs" ||
       units == "usecs" ||
       units == "hnsecs" ||
       units == "nsecs")
{
    return Duration(convert!(units, "hnsecs")(length));
}

alias weeks   = dur!"weeks";   /// Ditto
alias days    = dur!"days";    /// Ditto
alias hours   = dur!"hours";   /// Ditto
alias minutes = dur!"minutes"; /// Ditto
alias seconds = dur!"seconds"; /// Ditto
alias msecs   = dur!"msecs";   /// Ditto
alias usecs   = dur!"usecs";   /// Ditto
alias hnsecs  = dur!"hnsecs";  /// Ditto
alias nsecs   = dur!"nsecs";   /// Ditto

///
unittest
{
    // Generic
    assert(dur!"weeks"(142).total!"weeks" == 142);
    assert(dur!"days"(142).total!"days" == 142);
    assert(dur!"hours"(142).total!"hours" == 142);
    assert(dur!"minutes"(142).total!"minutes" == 142);
    assert(dur!"seconds"(142).total!"seconds" == 142);
    assert(dur!"msecs"(142).total!"msecs" == 142);
    assert(dur!"usecs"(142).total!"usecs" == 142);
    assert(dur!"hnsecs"(142).total!"hnsecs" == 142);
    assert(dur!"nsecs"(142).total!"nsecs" == 100);

    // Non-generic
    assert(weeks(142).total!"weeks" == 142);
    assert(days(142).total!"days" == 142);
    assert(hours(142).total!"hours" == 142);
    assert(minutes(142).total!"minutes" == 142);
    assert(seconds(142).total!"seconds" == 142);
    assert(msecs(142).total!"msecs" == 142);
    assert(usecs(142).total!"usecs" == 142);
    assert(hnsecs(142).total!"hnsecs" == 142);
    assert(nsecs(142).total!"nsecs" == 100);
}

unittest
{
    foreach (D; AliasSeq!(Duration, const Duration, immutable Duration))
    {
        assert(dur!"weeks"(7).total!"weeks" == 7);
        assert(dur!"days"(7).total!"days" == 7);
        assert(dur!"hours"(7).total!"hours" == 7);
        assert(dur!"minutes"(7).total!"minutes" == 7);
        assert(dur!"seconds"(7).total!"seconds" == 7);
        assert(dur!"msecs"(7).total!"msecs" == 7);
        assert(dur!"usecs"(7).total!"usecs" == 7);
        assert(dur!"hnsecs"(7).total!"hnsecs" == 7);
        assert(dur!"nsecs"(7).total!"nsecs" == 0);

        assert(dur!"weeks"(1007) == weeks(1007));
        assert(dur!"days"(1007) == days(1007));
        assert(dur!"hours"(1007) == hours(1007));
        assert(dur!"minutes"(1007) == minutes(1007));
        assert(dur!"seconds"(1007) == seconds(1007));
        assert(dur!"msecs"(1007) == msecs(1007));
        assert(dur!"usecs"(1007) == usecs(1007));
        assert(dur!"hnsecs"(1007) == hnsecs(1007));
        assert(dur!"nsecs"(10) == nsecs(10));
    }
}

/++
    Represents a timestamp of the system's monotonic clock.

    A monotonic clock is one which always goes forward and never moves
    backwards, unlike the system's wall clock time (as represented by
    $(REF SysTime, std,datetime)). The system's wall clock time can be adjusted
    by the user or by the system itself via services such as NTP, so it is
    unreliable to use the wall clock time for timing. Timers which use the wall
    clock time could easily end up never going off due to changes made to the
    wall clock time or otherwise waiting for a different period of time than
    that specified by the programmer. However, because the monotonic clock
    always increases at a fixed rate and is not affected by adjustments to the
    wall clock time, it is ideal for use with timers or anything which requires
    high precision timing.

    So, MonoTime should be used for anything involving timers and timing,
    whereas $(REF SysTime, std,datetime) should be used when the wall clock time
    is required.

    The monotonic clock has no relation to wall clock time. Rather, it holds
    its time as the number of ticks of the clock which have occurred since the
    clock started (typically when the system booted up). So, to determine how
    much time has passed between two points in time, one monotonic time is
    subtracted from the other to determine the number of ticks which occurred
    between the two points of time, and those ticks are divided by the number of
    ticks that occur every second (as represented by MonoTime.ticksPerSecond)
    to get a meaningful duration of time. Normally, MonoTime does these
    calculations for the programmer, but the $(D ticks) and $(D ticksPerSecond)
    properties are provided for those who require direct access to the system
    ticks. The normal way that MonoTime would be used is

--------------------
    MonoTime before = MonoTime.currTime;
    // do stuff...
    MonoTime after = MonoTime.currTime;
    Duration timeElapsed = after - before;
--------------------

  +/
struct MonoTime
{
@safe:

    // POD value, test mutable/const/immutable conversion
    version (CoreUnittest) unittest
    {
        MonoTime m;
        const MonoTime cm = m;
        immutable MonoTime im = m;
        m = cm;
        m = im;
    }

    /++
        The current time of the system's monotonic clock. This has no relation
        to the wall clock time, as the wall clock time can be adjusted (e.g.
        by NTP), whereas the monotonic clock always moves forward. The source
        of the monotonic time is system-specific.

        On Windows, $(D QueryPerformanceCounter) is used. On Mac OS X,
        $(D mach_absolute_time) is used, while on other POSIX systems,
        $(D clock_gettime) is used.

        $(RED Warning): On some systems, the monotonic clock may stop counting
                        when the computer goes to sleep or hibernates. So, the
                        monotonic clock may indicate less time than has actually
                        passed if that occurs. This is known to happen on
                        Mac OS X. It has not been tested whether it occurs on
                        either Windows or Linux.
      +/
    static @property MonoTime currTime() @trusted nothrow @nogc
    {
        if (ticksPerSecond == 0)
        {
            import core.internal.abort : abort;
            abort("MonoTime failed to get the frequency of the system's monotonic clock.");
        }

        version (WASIp1)
        {
            Timestamp ts = void;
            immutable error = clockTimeGet(ClockID.monotonic, 1, ts);
            if (error)
            {
                import core.internal.abort : abort;
                abort("Call to clockTimeGet failed.");
            }
            return MonoTime(convClockFreq(ts, 1_000_000_000L, ticksPerSecond));
        }
        else version (WASIp2)
        {
            return MonoTime(convClockFreq(monotonic_clock.now,
                                          1_000_000_000L,
                                          ticksPerSecond));
        }
    }


    static @property pure nothrow @nogc
    {
    /++
        A $(D MonoTime) of $(D 0) ticks. It's provided to be consistent with
        $(D Duration.zero), and it's more explicit than $(D MonoTime.init).
      +/
    MonoTime zero() { return MonoTime(0); }

    /++
        Largest $(D MonoTime) possible.
      +/
    MonoTime max() { return MonoTime(long.max); }

    /++
        Most negative $(D MonoTime) possible.
      +/
    MonoTime min() { return MonoTime(long.min); }
    }

    version (CoreUnittest) unittest
    {
        assert(MonoTime.zero == MonoTime(0));
        assert(MonoTime.max == MonoTime(long.max));
        assert(MonoTime.min == MonoTime(long.min));
        assert(MonoTime.min < MonoTime.zero);
        assert(MonoTime.zero < MonoTime.max);
        assert(MonoTime.min < MonoTime.max);
    }


    /++
        Compares this MonoTime with the given MonoTime.

        Returns:
            $(BOOKTABLE,
                $(TR $(TD this &lt; rhs) $(TD &lt; 0))
                $(TR $(TD this == rhs) $(TD 0))
                $(TR $(TD this &gt; rhs) $(TD &gt; 0))
            )
     +/
    int opCmp(MonoTime rhs) const pure nothrow @nogc
    {
        return (_ticks > rhs._ticks) - (_ticks < rhs._ticks);
    }

    version (CoreUnittest) unittest
    {
        import core.internal.traits : rvalueOf;
        const t = MonoTime.currTime;
        assert(t == rvalueOf(t));
    }

    version (CoreUnittest) unittest
    {
        import core.internal.traits : rvalueOf;
        const before = MonoTime.currTime;
        auto after = MonoTime(before._ticks + 42);
        assert(before < after);
        assert(rvalueOf(before) <= before);
        assert(rvalueOf(after) > before);
        assert(after >= rvalueOf(after));
    }

    version (CoreUnittest) unittest
    {
        const currTime = MonoTime.currTime;
        assert(MonoTime(long.max) > MonoTime(0));
        assert(MonoTime(0) > MonoTime(long.min));
        assert(MonoTime(long.max) > currTime);
        assert(currTime > MonoTime(0));
        assert(MonoTime(0) < currTime);
        assert(MonoTime(0) < MonoTime(long.max));
        assert(MonoTime(long.min) < MonoTime(0));
    }


    /++
        Subtracting two MonoTimes results in a $(LREF Duration) representing
        the amount of time which elapsed between them.

        The primary way that programs should time how long something takes is to
        do
--------------------
MonoTime before = MonoTime.currTime;
// do stuff
MonoTime after = MonoTime.currTime;

// How long it took.
Duration timeElapsed = after - before;
--------------------
        or to use a wrapper (such as a stop watch type) which does that.

        $(RED Warning):
            Because $(LREF Duration) is in hnsecs, whereas MonoTime is in system
            ticks, it's usually the case that this assertion will fail
--------------------
auto before = MonoTime.currTime;
// do stuff
auto after = MonoTime.currTime;
auto timeElapsed = after - before;
assert(before + timeElapsed == after);
--------------------

            This is generally fine, and by its very nature, converting from
            system ticks to any type of seconds (hnsecs, nsecs, etc.) will
            introduce rounding errors, but if code needs to avoid any of the
            small rounding errors introduced by conversion, then it needs to use
            MonoTime's $(D ticks) property and keep all calculations in ticks
            rather than using $(LREF Duration).
      +/
    Duration opBinary(string op)(MonoTime rhs) const pure nothrow @nogc
        if (op == "-")
    {
        immutable diff = _ticks - rhs._ticks;
        return Duration(convClockFreq(diff , ticksPerSecond, hnsecsPer!"seconds"));
    }

    version (CoreUnittest) unittest
    {
        import core.internal.traits : rvalueOf;
        const t = MonoTime.currTime;
        assert(t - rvalueOf(t) == Duration.zero);
        static assert(!__traits(compiles, t + t));
    }

    version (CoreUnittest) unittest
    {
        static void test(const scope MonoTime before, const scope MonoTime after, const scope Duration min)
        {
            immutable diff = after - before;
            assert(diff >= min);
            auto calcAfter = before + diff;
            assertApprox(calcAfter, calcAfter - Duration(1), calcAfter + Duration(1));
            assert(before - after == -diff);
        }

        const before = MonoTime.currTime;
        test(before, MonoTime(before._ticks + 4202), Duration.zero);
        test(before, MonoTime.currTime, Duration.zero);

        const durLargerUnits = dur!"minutes"(7) + dur!"seconds"(22);
        test(before, before + durLargerUnits + dur!"msecs"(33) + dur!"hnsecs"(571), durLargerUnits);
    }


    /++
        Adding or subtracting a $(LREF Duration) to/from a MonoTime results in
        a MonoTime which is adjusted by that amount.
      +/
    MonoTime opBinary(string op)(Duration rhs) const pure nothrow @nogc
        if (op == "+" || op == "-")
    {
        immutable rhsConverted = convClockFreq(rhs._hnsecs, hnsecsPer!"seconds", ticksPerSecond);
        mixin("return MonoTime(_ticks " ~ op ~ " rhsConverted);");
    }

    version (CoreUnittest) unittest
    {
        const t = MonoTime.currTime;
        assert(t + Duration(0) == t);
        assert(t - Duration(0) == t);
    }

    version (CoreUnittest) unittest
    {
        const t = MonoTime.currTime;

        // We reassign ticks in order to get the same rounding errors
        // that we should be getting with Duration (e.g. MonoTime may be
        // at a higher precision than hnsecs, meaning that 7333 would be
        // truncated when converting to hnsecs).
        long ticks = 7333;
        auto hnsecs = convClockFreq(ticks, ticksPerSecond, hnsecsPer!"seconds");
        ticks = convClockFreq(hnsecs, hnsecsPer!"seconds", ticksPerSecond);

        assert(t - Duration(hnsecs) == MonoTime(t._ticks - ticks));
        assert(t + Duration(hnsecs) == MonoTime(t._ticks + ticks));
    }


    /++ Ditto +/
    ref MonoTime opOpAssign(string op)(Duration rhs) pure nothrow @nogc
        if (op == "+" || op == "-")
    {
        immutable rhsConverted = convClockFreq(rhs._hnsecs, hnsecsPer!"seconds", ticksPerSecond);
        mixin("_ticks " ~ op ~ "= rhsConverted;");
        return this;
    }

    version (CoreUnittest) unittest
    {
        auto mt = MonoTime.currTime;
        const initial = mt;
        mt += Duration(0);
        assert(mt == initial);
        mt -= Duration(0);
        assert(mt == initial);

        // We reassign ticks in order to get the same rounding errors
        // that we should be getting with Duration (e.g. MonoTime may be
        // at a higher precision than hnsecs, meaning that 7333 would be
        // truncated when converting to hnsecs).
        long ticks = 7333;
        auto hnsecs = convClockFreq(ticks, ticksPerSecond, hnsecsPer!"seconds");
        ticks = convClockFreq(hnsecs, hnsecsPer!"seconds", ticksPerSecond);
        auto before = MonoTime(initial._ticks - ticks);

        assert((mt -= Duration(hnsecs)) == before);
        assert(mt  == before);
        assert((mt += Duration(hnsecs)) == initial);
        assert(mt  == initial);
    }


    /++
        The number of ticks in the monotonic time.

        Most programs should not use this directly, but it's exposed for those
        few programs that need it.

        The main reasons that a program might need to use ticks directly is if
        the system clock has higher precision than hnsecs, and the program needs
        that higher precision, or if the program needs to avoid the rounding
        errors caused by converting to hnsecs.
      +/
    @property long ticks() const pure nothrow @nogc
    {
        return _ticks;
    }

    version (CoreUnittest) unittest
    {
        const mt = MonoTime.currTime;
        assert(mt.ticks == mt._ticks);
    }


    /++
        The number of ticks that MonoTime has per second - i.e. the resolution
        or frequency of the system's monotonic clock.

        e.g. if the system clock had a resolution of microseconds, then
        ticksPerSecond would be $(D 1_000_000).
      +/
    static @property long ticksPerSecond() pure nothrow @nogc
    {
        return _ticksPerSecond;
    }

    ///
    string toString() const pure nothrow
    {
        return "MonoTime(" ~ signedToTempString(_ticks) ~ " ticks, " ~ signedToTempString(ticksPerSecond) ~ " ticks per second)";
    }

    version (CoreUnittest) unittest
    {
        import core.internal.util.math : min;

        static void eat(ref string s, const(char)[] exp)
        {
            assert(s[0 .. min($, exp.length)] == exp, s~" != "~exp);
            s = s[exp.length .. $];
        }

        immutable mt = MonoTime.currTime;
        auto str = mt.toString();
        eat(str, "MonoTime(");

        eat(str, signedToTempString(mt._ticks));
        eat(str, " ticks, ");
        eat(str, signedToTempString(ticksPerSecond));
        eat(str, " ticks per second)");
    }

private:

    // This is supposed to be initialized by a static constructor,
    // but https://issues.dlang.org/show_bug.cgi?id=14517 prevents that from
    // working. However, moving it back to a static ctor will
    // reraise issues with other systems using MonoTime, so we should leave the
    // initialization as-is even when that bug is fixed.
    static immutable long _ticksPerSecond;

    long _ticks;
}

// This is called directly from the runtime initilization function (rt_init),
// instead of using a static constructor. Other subsystems inside the runtime
// (namely, the GC) may need time functionality, but cannot wait until the
// static ctors have run. Therefore, we initialize these specially. Because
// it's a normal function, we need to do some dangerous casting PLEASE take
// care when modifying this function, and it should NOT be called except from
// the runtime init.
//
// NOTE: the code below SPECIFICALLY does not assert when it cannot initialize
// the ticks per second. This allows cases where a clock is never used on
// a system that doesn't support it. See bugzilla issue
// https://issues.dlang.org/show_bug.cgi?id=14863
// The assert will occur when someone attempts to use _ticksPerSecond for that
// value.
extern(C) void _d_initMonoTime() @nogc nothrow
{
    // If we try to do anything with ClockType in the documentation build, it'll
    // trigger the static assertions related to ClockType, since the
    // documentation build defines all of the possible ClockTypes, which won't
    // work when they're used in the static ifs, because no system supports them
    // all.
    version (CoreDdoc)
    {}
    else version (WASIp1)
    {
        Timestamp ts;
        
        if (clockResGet(ClockID.monotonic, ts) == Errno.success)
        {
            // ensure we are only writing immutable data once
            if (MonoTime._ticksPerSecond != 0)
                // should only be called once
                assert(0);

            
            // We need to modify ticksPerSecond. Although this
            // would appear to break immutability, it is logically the same as a static
            // ctor. So we should ONLY write these values once (we will check for 0
            // values when setting to ensure this is truly only called once).
            cast()MonoTime._ticksPerSecond = 1_000_000_000L / ts;
        }
    }
    else version (WASIp2)
    {
        // ensure we are only writing immutable data once
        if (MonoTime._ticksPerSecond != 0)
            // should only be called once
            assert(0);

        cast()MonoTime._ticksPerSecond = 1_000_000_000L / monotonic_clock.resolution;
    }
}


// Tests for MonoTime.currTime. It has to be outside, because MonoTime
// is a template. This unittest block also makes sure that MonoTime actually
// is instantiated with all of the various ClockTypes so that those types and
// their tests are compiled and run.
unittest
{
    auto norm1 = MonoTime.currTime;
    auto norm2 = MonoTime.currTime;
    assert(norm1 <= norm2);

    auto v1 = MonoTime.currTime;
    auto v2 = MonoTime.currTime;
    scope(failure)
    {
        printf("normal: v1 %s, v2 %s, tps %s\n",
                numToStringz(v1._ticks),
                numToStringz(v2._ticks),
                numToStringz(typeof(v1).ticksPerSecond));
    }
    assert(v1 <= v2);
}


/++
    Converts the given time from one clock frequency/resolution to another.

    See_Also:
        $(LREF ticksToNSecs)
  +/
long convClockFreq(long ticks, long srcTicksPerSecond, long dstTicksPerSecond) @safe pure nothrow @nogc
{
    // This would be more straightforward with floating point arithmetic,
    // but we avoid it here in order to avoid the rounding errors that that
    // introduces. Also, by splitting out the units in this way, we're able
    // to deal with much larger values before running into problems with
    // integer overflow.
    return ticks / srcTicksPerSecond * dstTicksPerSecond +
           ticks % srcTicksPerSecond * dstTicksPerSecond / srcTicksPerSecond;
}

///
unittest
{
    // one tick is one second -> one tick is a hecto-nanosecond
    assert(convClockFreq(45, 1, 10_000_000) == 450_000_000);

    // one tick is one microsecond -> one tick is a millisecond
    assert(convClockFreq(9029, 1_000_000, 1_000) == 9);

    // one tick is 1/3_515_654 of a second -> 1/1_001_010 of a second
    assert(convClockFreq(912_319, 3_515_654, 1_001_010) == 259_764);

    // one tick is 1/MonoTime.ticksPerSecond -> one tick is a nanosecond
    // Equivalent to ticksToNSecs
    auto nsecs = convClockFreq(1982, MonoTime.ticksPerSecond, 1_000_000_000);
}

unittest
{
    assert(convClockFreq(99, 43, 57) == 131);
    assert(convClockFreq(131, 57, 43) == 98);
    assert(convClockFreq(1234567890, 10_000_000, 1_000_000_000) == 123456789000);
    assert(convClockFreq(1234567890, 1_000_000_000, 10_000_000) == 12345678);
    assert(convClockFreq(123456789000, 1_000_000_000, 10_000_000) == 1234567890);
    assert(convClockFreq(12345678, 10_000_000, 1_000_000_000) == 1234567800);
    assert(convClockFreq(13131, 3_515_654, 10_000_000) == 37350);
    assert(convClockFreq(37350, 10_000_000, 3_515_654) == 13130);
    assert(convClockFreq(37350, 3_515_654, 10_000_000) == 106239);
    assert(convClockFreq(106239, 10_000_000, 3_515_654) == 37349);

    // It would be too expensive to cover a large range of possible values for
    // ticks, so we use random values in an attempt to get reasonable coverage.
    import core.stdc.stdlib : rand, srand;
    version (WASIp1) {
        Timestamp ts;
        clockTimeGet(ClockID.realtime, 1, ts);
        immutable seed = cast(int)(ts / 1_000_000_000);
    } else version (WASIp2) {
        import wall_clock = wasm_drt.wasip2.clocks.wall_clock.imports;
        immutable seed = cast(int)wall_clock.now.seconds;
    }
    srand(seed);
    scope(failure) printf("seed %d\n", seed);
    enum freq1 = 5_527_551L;
    enum freq2 = 10_000_000L;
    enum freq3 = 1_000_000_000L;
    enum freq4 = 98_123_320L;
    immutable freq5 = MonoTime.ticksPerSecond;

    // This makes it so that freq6 is the first multiple of 10 which is greater
    // than or equal to freq5, which at one point was considered for MonoTime's
    // ticksPerSecond rather than using the system's actual clock frequency, so
    // it seemed like a good test case to have.
    import core.stdc.math : floor, log10, pow;
    immutable numDigitsMinus1 = cast(int)floor(log10(freq5));
    auto freq6 = cast(long)pow(10, numDigitsMinus1);
    if (freq5 > freq6)
        freq6 *= 10;

    foreach (_; 0 .. 10_000)
    {
        long[2] values = [rand(), cast(long)rand() * (rand() % 16)];
        foreach (i; values)
        {
            scope(failure) printf("i %s\n", numToStringz(i));
            assertApprox(convClockFreq(convClockFreq(i, freq1, freq2), freq2, freq1), i - 10, i + 10);
            assertApprox(convClockFreq(convClockFreq(i, freq2, freq1), freq1, freq2), i - 10, i + 10);

            assertApprox(convClockFreq(convClockFreq(i, freq3, freq4), freq4, freq3), i - 100, i + 100);
            assertApprox(convClockFreq(convClockFreq(i, freq4, freq3), freq3, freq4), i - 100, i + 100);

            scope(failure) printf("sys %s mt %s\n", numToStringz(freq5), numToStringz(freq6));
            assertApprox(convClockFreq(convClockFreq(i, freq5, freq6), freq6, freq5), i - 10, i + 10);
            assertApprox(convClockFreq(convClockFreq(i, freq6, freq5), freq5, freq6), i - 10, i + 10);

            // This is here rather than in a unittest block immediately after
            // ticksToNSecs in order to avoid code duplication in the unit tests.
            assert(convClockFreq(i, MonoTime.ticksPerSecond, 1_000_000_000) == ticksToNSecs(i));
        }
    }
}


/++
    Convenience wrapper around $(LREF convClockFreq) which converts ticks at
    a clock frequency of $(D MonoTime.ticksPerSecond) to nanoseconds.

    It's primarily of use when $(D MonoTime.ticksPerSecond) is greater than
    hecto-nanosecond resolution, and an application needs a higher precision
    than hecto-nanoceconds.

    See_Also:
        $(LREF convClockFreq)
  +/
long ticksToNSecs(long ticks) @safe pure nothrow @nogc
{
    return convClockFreq(ticks, MonoTime.ticksPerSecond, 1_000_000_000);
}

///
unittest
{
    auto before = MonoTime.currTime;
    // do stuff
    auto after = MonoTime.currTime;
    auto diffInTicks = after.ticks - before.ticks;
    auto diffInNSecs = ticksToNSecs(diffInTicks);
    assert(diffInNSecs == convClockFreq(diffInTicks, MonoTime.ticksPerSecond, 1_000_000_000));
}


/++
    The reverse of $(LREF ticksToNSecs).
  +/
long nsecsToTicks(long ticks) @safe pure nothrow @nogc
{
    return convClockFreq(ticks, 1_000_000_000, MonoTime.ticksPerSecond);
}

unittest
{
    long ticks = 123409832717333;
    auto nsecs = convClockFreq(ticks, MonoTime.ticksPerSecond, 1_000_000_000);
    ticks = convClockFreq(nsecs, 1_000_000_000, MonoTime.ticksPerSecond);
    assert(nsecsToTicks(nsecs) == ticks);
}

/++
    Generic way of converting between two time units. Conversions to smaller
    units use truncating division. Years and months can be converted to each
    other, small units can be converted to each other, but years and months
    cannot be converted to or from smaller units (due to the varying number
    of days in a month or year).

    Params:
        from  = The units of time to convert from.
        to    = The units of time to convert to.
        value = The value to convert.
  +/
long convert(string from, string to)(long value) @safe pure nothrow @nogc
    if (((from == "weeks" ||
         from == "days" ||
         from == "hours" ||
         from == "minutes" ||
         from == "seconds" ||
         from == "msecs" ||
         from == "usecs" ||
         from == "hnsecs" ||
         from == "nsecs") &&
        (to == "weeks" ||
         to == "days" ||
         to == "hours" ||
         to == "minutes" ||
         to == "seconds" ||
         to == "msecs" ||
         to == "usecs" ||
         to == "hnsecs" ||
         to == "nsecs")) ||
       ((from == "years" || from == "months") && (to == "years" || to == "months")))
{
    static if (from == "years")
    {
        static if (to == "years")
            return value;
        else static if (to == "months")
            return value * 12;
        else
            static assert(0, "A generic month or year cannot be converted to or from smaller units.");
    }
    else static if (from == "months")
    {
        static if (to == "years")
            return value / 12;
        else static if (to == "months")
            return value;
        else
            static assert(0, "A generic month or year cannot be converted to or from smaller units.");
    }
    else static if (from == "nsecs" && to == "nsecs")
        return value;
    else static if (from == "nsecs")
        return convert!("hnsecs", to)(value / 100);
    else static if (to == "nsecs")
        return convert!(from, "hnsecs")(value) * 100;
    else
        return (hnsecsPer!from * value) / hnsecsPer!to;
}

///
unittest
{
    assert(convert!("years", "months")(1) == 12);
    assert(convert!("months", "years")(12) == 1);

    assert(convert!("weeks", "days")(1) == 7);
    assert(convert!("hours", "seconds")(1) == 3600);
    assert(convert!("seconds", "days")(1) == 0);
    assert(convert!("seconds", "days")(86_400) == 1);

    assert(convert!("nsecs", "nsecs")(1) == 1);
    assert(convert!("nsecs", "hnsecs")(1) == 0);
    assert(convert!("hnsecs", "nsecs")(1) == 100);
    assert(convert!("nsecs", "seconds")(1) == 0);
    assert(convert!("seconds", "nsecs")(1) == 1_000_000_000);
}

unittest
{
    foreach (units; AliasSeq!("weeks", "days", "hours", "seconds", "msecs", "usecs", "hnsecs", "nsecs"))
    {
        static assert(!__traits(compiles, convert!("years", units)(12)), units);
        static assert(!__traits(compiles, convert!(units, "years")(12)), units);
    }

    foreach (units; AliasSeq!("years", "months", "weeks", "days",
                               "hours", "seconds", "msecs", "usecs", "hnsecs", "nsecs"))
    {
        assert(convert!(units, units)(12) == 12);
    }

    assert(convert!("weeks", "hnsecs")(1) == 6_048_000_000_000L);
    assert(convert!("days", "hnsecs")(1) == 864_000_000_000L);
    assert(convert!("hours", "hnsecs")(1) == 36_000_000_000L);
    assert(convert!("minutes", "hnsecs")(1) == 600_000_000L);
    assert(convert!("seconds", "hnsecs")(1) == 10_000_000L);
    assert(convert!("msecs", "hnsecs")(1) == 10_000);
    assert(convert!("usecs", "hnsecs")(1) == 10);

    assert(convert!("hnsecs", "weeks")(6_048_000_000_000L) == 1);
    assert(convert!("hnsecs", "days")(864_000_000_000L) == 1);
    assert(convert!("hnsecs", "hours")(36_000_000_000L) == 1);
    assert(convert!("hnsecs", "minutes")(600_000_000L) == 1);
    assert(convert!("hnsecs", "seconds")(10_000_000L) == 1);
    assert(convert!("hnsecs", "msecs")(10_000) == 1);
    assert(convert!("hnsecs", "usecs")(10) == 1);

    assert(convert!("weeks", "days")(1) == 7);
    assert(convert!("days", "weeks")(7) == 1);

    assert(convert!("days", "hours")(1) == 24);
    assert(convert!("hours", "days")(24) == 1);

    assert(convert!("hours", "minutes")(1) == 60);
    assert(convert!("minutes", "hours")(60) == 1);

    assert(convert!("minutes", "seconds")(1) == 60);
    assert(convert!("seconds", "minutes")(60) == 1);

    assert(convert!("seconds", "msecs")(1) == 1000);
    assert(convert!("msecs", "seconds")(1000) == 1);

    assert(convert!("msecs", "usecs")(1) == 1000);
    assert(convert!("usecs", "msecs")(1000) == 1);

    assert(convert!("usecs", "hnsecs")(1) == 10);
    assert(convert!("hnsecs", "usecs")(10) == 1);

    assert(convert!("weeks", "nsecs")(1) == 604_800_000_000_000L);
    assert(convert!("days", "nsecs")(1) == 86_400_000_000_000L);
    assert(convert!("hours", "nsecs")(1) == 3_600_000_000_000L);
    assert(convert!("minutes", "nsecs")(1) == 60_000_000_000L);
    assert(convert!("seconds", "nsecs")(1) == 1_000_000_000L);
    assert(convert!("msecs", "nsecs")(1) == 1_000_000);
    assert(convert!("usecs", "nsecs")(1) == 1000);
    assert(convert!("hnsecs", "nsecs")(1) == 100);

    assert(convert!("nsecs", "weeks")(604_800_000_000_000L) == 1);
    assert(convert!("nsecs", "days")(86_400_000_000_000L) == 1);
    assert(convert!("nsecs", "hours")(3_600_000_000_000L) == 1);
    assert(convert!("nsecs", "minutes")(60_000_000_000L) == 1);
    assert(convert!("nsecs", "seconds")(1_000_000_000L) == 1);
    assert(convert!("nsecs", "msecs")(1_000_000) == 1);
    assert(convert!("nsecs", "usecs")(1000) == 1);
    assert(convert!("nsecs", "hnsecs")(100) == 1);
}

/++
    Exception type used by core.time.
  +/
class TimeException : Exception
{
    /++
        Params:
            msg  = The message for the exception.
            file = The file where the exception occurred.
            line = The line number where the exception occurred.
            next = The previous exception in the chain of exceptions, if any.
      +/
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) @safe pure nothrow
    {
        super(msg, file, line, next);
    }

    /++
        Params:
            msg  = The message for the exception.
            next = The previous exception in the chain of exceptions.
            file = The file where the exception occurred.
            line = The line number where the exception occurred.
      +/
    this(string msg, Throwable next, string file = __FILE__, size_t line = __LINE__) @safe pure nothrow
    {
        super(msg, file, line, next);
    }
}

unittest
{
    {
        auto e = new TimeException("hello");
        assert(e.msg == "hello");
        assert(e.file == __FILE__);
        assert(e.line == __LINE__ - 3);
        assert(e.next is null);
    }

    {
        auto next = new Exception("foo");
        auto e = new TimeException("goodbye", next);
        assert(e.msg == "goodbye");
        assert(e.file == __FILE__);
        assert(e.line == __LINE__ - 3);
        assert(e.next is next);
    }
}



/++
    Returns the absolute value of a duration.
  +/
Duration abs(Duration duration) @safe pure nothrow @nogc
{
    return Duration(_abs(duration._hnsecs));
}

unittest
{
    assert(abs(dur!"msecs"(5)) == dur!"msecs"(5));
    assert(abs(dur!"msecs"(-5)) == dur!"msecs"(5));
}

//==============================================================================
// Private Section.
//
// Much of this is a copy or simplified copy of what's in std.datetime.
//==============================================================================
private:


/+
    Template to help with converting between time units.
 +/
template hnsecsPer(string units)
    if (units == "weeks" ||
       units == "days" ||
       units == "hours" ||
       units == "minutes" ||
       units == "seconds" ||
       units == "msecs" ||
       units == "usecs" ||
       units == "hnsecs")
{
    static if (units == "hnsecs")
        enum hnsecsPer = 1L;
    else static if (units == "usecs")
        enum hnsecsPer = 10L;
    else static if (units == "msecs")
        enum hnsecsPer = 1000 * hnsecsPer!"usecs";
    else static if (units == "seconds")
        enum hnsecsPer = 1000 * hnsecsPer!"msecs";
    else static if (units == "minutes")
        enum hnsecsPer = 60 * hnsecsPer!"seconds";
    else static if (units == "hours")
        enum hnsecsPer = 60 * hnsecsPer!"minutes";
    else static if (units == "days")
        enum hnsecsPer = 24 * hnsecsPer!"hours";
    else static if (units == "weeks")
        enum hnsecsPer = 7 * hnsecsPer!"days";
}

/+
    Splits out a particular unit from hnsecs and gives you the value for that
    unit and the remaining hnsecs. It really shouldn't be used unless all units
    larger than the given units have already been split out.

    Params:
        units  = The units to split out.
        hnsecs = The current total hnsecs. Upon returning, it is the hnsecs left
                 after splitting out the given units.

    Returns:
        The number of the given units from converting hnsecs to those units.
  +/
long splitUnitsFromHNSecs(string units)(ref long hnsecs) @safe pure nothrow @nogc
    if (units == "weeks" ||
       units == "days" ||
       units == "hours" ||
       units == "minutes" ||
       units == "seconds" ||
       units == "msecs" ||
       units == "usecs" ||
       units == "hnsecs")
{
    immutable value = convert!("hnsecs", units)(hnsecs);
    hnsecs -= convert!(units, "hnsecs")(value);

    return value;
}

unittest
{
    auto hnsecs = 2595000000007L;
    immutable days = splitUnitsFromHNSecs!"days"(hnsecs);
    assert(days == 3);
    assert(hnsecs == 3000000007);

    immutable minutes = splitUnitsFromHNSecs!"minutes"(hnsecs);
    assert(minutes == 5);
    assert(hnsecs == 7);
}

/+
    Whether all of the given strings are among the accepted strings.
  +/
bool allAreAcceptedUnits(acceptedUnits...)(scope string[] units)
{
    foreach (unit; units)
    {
        bool found = false;
        foreach (acceptedUnit; acceptedUnits)
        {
            if (unit == acceptedUnit)
            {
                found = true;
                break;
            }
        }
        if (!found)
            return false;
    }
    return true;
}

unittest
{
    assert(allAreAcceptedUnits!("hours", "seconds")(["seconds", "hours"]));
    assert(!allAreAcceptedUnits!("hours", "seconds")(["minutes", "hours"]));
    assert(!allAreAcceptedUnits!("hours", "seconds")(["seconds", "minutes"]));
    assert(allAreAcceptedUnits!("days", "hours", "minutes", "seconds", "msecs")(["minutes"]));
    assert(!allAreAcceptedUnits!("days", "hours", "minutes", "seconds", "msecs")(["usecs"]));
    assert(!allAreAcceptedUnits!("days", "hours", "minutes", "seconds", "msecs")(["secs"]));
}


/+
    Whether the given time unit strings are arranged in order from largest to
    smallest.
  +/
bool unitsAreInDescendingOrder(scope string[] units)
{
    if (units.length <= 1)
        return true;

    immutable string[] timeStrings = ["nsecs", "hnsecs", "usecs", "msecs", "seconds",
                                      "minutes", "hours", "days", "weeks", "months", "years"];
    size_t currIndex = 42;
    foreach (i, timeStr; timeStrings)
    {
        if (units[0] == timeStr)
        {
            currIndex = i;
            break;
        }
    }
    assert(currIndex != 42);

    foreach (unit; units[1 .. $])
    {
        size_t nextIndex = 42;
        foreach (i, timeStr; timeStrings)
        {
            if (unit == timeStr)
            {
                nextIndex = i;
                break;
            }
        }
        assert(nextIndex != 42);

        if (currIndex <= nextIndex)
            return false;
        currIndex = nextIndex;
    }
    return true;
}

unittest
{
    assert(unitsAreInDescendingOrder(["years", "months", "weeks", "days", "hours", "minutes",
                                     "seconds", "msecs", "usecs", "hnsecs", "nsecs"]));
    assert(unitsAreInDescendingOrder(["weeks", "hours", "msecs"]));
    assert(unitsAreInDescendingOrder(["days", "hours", "minutes"]));
    assert(unitsAreInDescendingOrder(["hnsecs"]));
    assert(!unitsAreInDescendingOrder(["days", "hours", "hours"]));
    assert(!unitsAreInDescendingOrder(["days", "hours", "days"]));
}

/+
    Local version of abs, since std.math.abs is in Phobos, not druntime.
  +/
long _abs(long val) @safe pure nothrow @nogc
{
    return val >= 0 ? val : -val;
}

double _abs(double val) @safe pure nothrow @nogc
{
    return val >= 0.0 ? val : -val;
}


version (CoreUnittest)
string doubleToString(double value) @safe pure nothrow
{
    string result;
    if (value < 0 && cast(long)value == 0)
        result = "-0";
    else
        result = signedToTempString(cast(long)value).idup;
    result ~= '.';
    result ~= unsignedToTempString(cast(ulong)(_abs((value - cast(long)value) * 1_000_000) + .5));

    while (result[$-1] == '0')
        result = result[0 .. $-1];
    return result;
}

unittest
{
    auto a = 1.337;
    auto aStr = doubleToString(a);
    assert(aStr == "1.337", aStr);

    a = 0.337;
    aStr = doubleToString(a);
    assert(aStr == "0.337", aStr);

    a = -0.337;
    aStr = doubleToString(a);
    assert(aStr == "-0.337", aStr);
}

version (CoreUnittest) const(char)* numToStringz()(long value) @trusted pure nothrow
{
    return (signedToTempString(value) ~ "\0").ptr;
}


/+
    dmd @@@BUG18223@@@
    A selective import of `AliasSeq` happens to bleed through and causes symbol clashes downstream.
 +/
version (none)
    import core.internal.traits : AliasSeq;
else
    import core.internal.traits;


/+ An adjusted copy of std.exception.assertThrown. +/
version (CoreUnittest) void _assertThrown(T : Throwable = Exception, E)
                                    (lazy E expression,
                                     string msg = null,
                                     string file = __FILE__,
                                     size_t line = __LINE__)
{
    bool thrown = false;

    try
        expression();
    catch (T t)
        thrown = true;

    if (!thrown)
    {
        immutable tail = msg.length == 0 ? "." : ": " ~ msg;

        throw new AssertError("assertThrown() failed: No " ~ T.stringof ~ " was thrown" ~ tail, file, line);
    }
}

unittest
{

    void throwEx(Throwable t)
    {
        throw t;
    }

    void nothrowEx()
    {}

    try
        _assertThrown!Exception(throwEx(new Exception("It's an Exception")));
    catch (AssertError)
        assert(0);

    try
        _assertThrown!Exception(throwEx(new Exception("It's an Exception")), "It's a message");
    catch (AssertError)
        assert(0);

    try
        _assertThrown!AssertError(throwEx(new AssertError("It's an AssertError", __FILE__, __LINE__)));
    catch (AssertError)
        assert(0);

    try
        _assertThrown!AssertError(throwEx(new AssertError("It's an AssertError", __FILE__, __LINE__)), "It's a message");
    catch (AssertError)
        assert(0);


    {
        bool thrown = false;
        try
            _assertThrown!Exception(nothrowEx());
        catch (AssertError)
            thrown = true;

        assert(thrown);
    }

    {
        bool thrown = false;
        try
            _assertThrown!Exception(nothrowEx(), "It's a message");
        catch (AssertError)
            thrown = true;

        assert(thrown);
    }

    {
        bool thrown = false;
        try
            _assertThrown!AssertError(nothrowEx());
        catch (AssertError)
            thrown = true;

        assert(thrown);
    }

    {
        bool thrown = false;
        try
            _assertThrown!AssertError(nothrowEx(), "It's a message");
        catch (AssertError)
            thrown = true;

        assert(thrown);
    }
}

version (CoreUnittest) void assertApprox(D, E)(D actual,
                                          E lower,
                                          E upper,
                                          string msg = "unittest failure",
                                          size_t line = __LINE__)
    if (is(D : const Duration) && is(E : const Duration))
{
    if (actual < lower)
        throw new AssertError(msg ~ ": lower: " ~ actual.toString(), __FILE__, line);
    if (actual > upper)
        throw new AssertError(msg ~ ": upper: " ~ actual.toString(), __FILE__, line);
}

version (CoreUnittest) void assertApprox()(MonoTime actual,
                                        MonoTime lower,
                                        MonoTime upper,
                                        string msg = "unittest failure",
                                        size_t line = __LINE__)
{
    assertApprox(actual._ticks, lower._ticks, upper._ticks, msg, line);
}

version (CoreUnittest) void assertApprox()(long actual,
                                      long lower,
                                      long upper,
                                      string msg = "unittest failure",
                                      size_t line = __LINE__)
{
    if (actual < lower)
        throw new AssertError(msg ~ ": lower: " ~ signedToTempString(actual).idup, __FILE__, line);
    if (actual > upper)
        throw new AssertError(msg ~ ": upper: " ~ signedToTempString(actual).idup, __FILE__, line);
}
