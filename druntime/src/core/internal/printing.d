module core.internal.printing;

import core.stdc.stdio : FILE, fputc, fwrite;
import core.internal.string;

void writeStrings(FILE* file, scope const(char)[][] strs...) @nogc nothrow
{
    foreach (str; strs)
        file.writeStr(str);
}

void writeStr(FILE* file, scope const(char)[] str) @nogc nothrow
{
    fwrite(str.ptr, 1, str.length, file);
}

void writeUnsigned(ubyte radix = 10)(FILE* file, ulong val, uint width = 0) @nogc nothrow
{
    UnsignedStringBuf buf = ' ';
    auto str = val.unsignedToTempString!radix(buf);

    width = (buf.length < width) ? buf.length : width;
    width = (str.length > width) ? str.length : width;

    file.writeStr(buf[buf.length - width .. $]);
}

void writeSigned(ubyte radix = 10)(FILE* file, long val, uint width = 0) @nogc nothrow
{
    SignedStringBuf buf = ' ';
    auto str = val.signedToTempString!radix(buf);

    width = (buf.length < width) ? buf.length : width;
    width = (str.length > width) ? str.length : width;

    file.writeStr(buf[buf.length - width .. $]);
}

void writeLine(FILE* file, scope const(char)[][] msg...) @nogc nothrow
{
    file.writeStrings(msg);
    file.writeChar('\n');
}

void writeChar(FILE* file, char c) @nogc nothrow
{
    fputc(c, file);
}
