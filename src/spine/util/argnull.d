module spine.util.argnull;

import std.string;
version(unittest) {
    import std.stdio : write, writeln;
    import std.exception; 
}

template ArgNull(alias argument) {
    enum ArgNull = format(
    "if(%1$s is null)
        throw new Exception(\"%1$s cannot be null.\");", argument.stringof);
}

unittest {
    void func(string str) {
        mixin(ArgNull!str);
    }
    assertThrown(func(null));
    assertNotThrown(func("test"));
}