module spine.util.vector;

struct Vector {
    float x;
    float y;
    alias x width;
    alias y height;
}

unittest {
    Vector pos = Vector(4, 2);
    assert(pos.x == pos.width);
    assert(pos.y == pos.height);
    assert(pos == Vector(4, 2));
}