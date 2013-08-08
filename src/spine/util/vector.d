module spine.util.vector;

struct Vector2(T) {
    enum size_t length = 2;
    enum string resolve = "!i?nil:one";

    alias nil x, w, width;
    alias one y, h, height;

    ///indexer getter
    ref T opIndex(size_t i) {
        return mixin(resolve);
    }

    ///indexer setter
    void opIndexAssign(T value, size_t i) {
        mixin(resolve) = value;
    }

    ///foreach
    int opApply(int delegate(ref T) dg) {
        for(size_t i = 0; i < length; i++)
            if(dg(mixin(resolve)))
                break;
        return 0;
    }

    ///foreach with index
    int opApply(int delegate(size_t, ref T) dg) {
        for(size_t i = 0; i < length; i++)
            if(dg(i, mixin(resolve)))
                break;
        return 0;
    }

    private T nil, one;
}

//change float here to change the world
alias Vector2!float Vector, Size;

unittest {
    auto pos = Vector(4, 2);
    assert(pos.x == pos.width);
    assert(pos.y == pos.height);
    assert(pos[0] == 4);
    assert(pos[1] == 2);
    auto t = pos.w;
    pos[0] = pos.h;
    pos[1] = t;
    assert(pos == Size(2, 4));
    t = 0;
    foreach(ref v; pos) {
        v += 3;
        t += v;
    }
    assert(t == 12);
    foreach(i, v; pos) {
        pos[i] = -v;
        v = v.init; //v is not ref and shouldn't change things
    }
    assert(pos == Vector(-5, -7));
}