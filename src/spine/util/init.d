module spine.util.init;

debug import std.stdio;

@property auto init(Target)() {
    debug writeln(Target.init);
    return Target.init;
}

@property auto init(Source, Target)() {
    return init!Source.to!Target;
}

@property void init(Source, Target)(out Target target) {
    target = init!(Source, Target);
}

unittest {
    struct MyInt {
        alias x this;
        private int x;
    }

    MyInt f;
    init!bool(f);

    auto v = init!float; // the same as float.init

    v.init!bool;
    debug v.writeln;

    string str = init!(int, string);
    debug str.writeln;
}