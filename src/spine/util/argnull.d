module spine.util.argnull;

import std.string : format;

template ArgNull(alias argument) {
    enum ArgNull = format(
    "if(%1$s is null)
        throw new Exception(\"%1$s cannot be null.\");", argument.stringof);
}

unittest {
    import std.exception;
    void func(string str) {
        mixin(ArgNull!str);
    }
    assertThrown(func(null));
    assertNotThrown(func("test"));
}