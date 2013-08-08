module spine.util.init;

import std.conv : to;

@property auto init(Target, Source = Target)() {
    return Source.init.to!Target;
}

@property void init(Target, Source = Target)(out Target target) {
    target = init!(Target, Source);
}

unittest {
    int n = init!bool;
    assert(n == 0);

    long l;
    l.init!(long, uint);
    assert(l == uint.init);

    auto boolean = init!(string, bool);
    assert(is(typeof(boolean) == string));
    assert(boolean == "false");

    class Foo {} //test subject
    auto nullFoo = init!(string, Foo);
    assert(is(typeof(nullFoo) == string));
    assert(nullFoo == "null");
}