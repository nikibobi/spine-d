module spine.bone;

import spine.util;

static import std.math;

export:

class BoneData {

    this(string name, BoneData parent = null) {
        mixin(ArgNull!name);
        this.name = name;
        this.parent = parent;
        this.scaleX = 1;
        this.scaleY = 1;
    }

    unittest {
        debug {
            import std.stdio;
            writeln("Test: BoneData");
        }
        
        import std.exception;
        assertThrown(new BoneData(null));

        auto b = new BoneData("child", new BoneData("parent"));
        assert(b.name == "child");
        assert(b.parent.name == "parent");
        assert(b.scaleX == 1);
        assert(b.scaleY == 1);
    }

    @property {
        BoneData parent() {
            return _parent;
        }
        private void parent(BoneData value) {
            _parent = value;
        }
    }

    @property {
        string name() {
            return _name;
        }
        private void name(string value) {
            _name = value;
        }
    }

    @property {
        float length() {
            return _length;
        }
        void length(float value) {
            _length = value;
        }
    }

    @property {
        float x() {
            return _x;
        }
        void x(float value) {
            _x = value;
        }
    }

    @property {
        float y() {
            return _y;
        }
        void y(float value) {
            _y = value;
        }
    }

    @property {
        float rotation() {
            return _rotation;
        }
        void rotation(float value) {
            _rotation = value;
        }
    }

    @property {
        float scaleX() {
            return _scaleX;
        }
        void scaleX(float value) {
            _scaleX = value;
        }
    }

    @property {
        float scaleY() {
            return _scaleY;
        }
        void scaleY(float value) {
            _scaleY = value;
        }
    }

    @property {
        bool inheritScale() {
            return _inheritScale;
        }
        void inheritScale(bool value) {
            _inheritScale = value;
        }
    }

    @property {
        bool inheritRotation() {
            return _inheritRotation;
        }
        void inheritRotation(bool value) {
            _inheritRotation = value;
        }
    }

    override string toString() {
        return name;
    }

private:
    BoneData _parent;
    string _name;
    float _length;
    float _x, _y;
    float _rotation;
    float _scaleX, _scaleY;
    bool _inheritScale;
    bool _inheritRotation;
}

class Bone {

    static bool yDown;

    this(BoneData data, Bone parent) {
        mixin(ArgNull!data);
        this.data = data;
        this.parent = parent;
        setToSetupPose();        
    }

    @property {
        BoneData data() {
            return _data;
        }
        private void data(BoneData value) {
            _data = value;
        }
    }

    @property {
        Bone parent() {
            return _parent;
        }
        private void parent(Bone value) {
            _parent = value;
        }
    }

    @property {
        float x() {
            return _x;
        }
        void x(float value) {
            _x = value;
        }
    }

    @property {
        float y() {
            return _y;
        }
        void y(float value) {
            _y = value;
        }
    }

    @property {
        float rotation() {
            return _rotation;
        }
        void rotation(float value) {
            _rotation = value;
        }
    }

    @property {
        float scaleX() {
            return _scaleX;
        }
        void scaleX(float value) {
            _scaleX = value;
        }
    }

    @property {
        float scaleY() {
            return _scaleY;
        }
        void scaleY(float value) {
            _scaleY = value;
        }
    }

    @property {
        float m00() {
            return _m00;
        }
        private void m00(float value) {
            _m00 = value;
        }
    }

    @property {
        float m01() {
            return _m01;
        }
        private void m01(float value) {
            _m01 = value;
        }
    }

    @property {
        float m10() {
            return _m10;
        }
        private void m10(float value) {
            _m10 = value;
        }
    }

    @property {
        float m11() {
            return _m11;
        }
        private void m11(float value) {
            _m11 = value;
        }
    }

    @property {
        float worldX() {
            return _worldX;
        }
        private void worldX(float value) {
            _worldX = value;
        }
    }

    @property {
        float worldY() {
            return _worldY;
        }
        private void worldY(float value) {
            _worldY = value;
        }
    }

    @property {
        float worldRotation() {
            return _worldRotation;
        }
        private void worldRotation(float value) {
            _worldRotation = value;
        }
    }

    @property {
        float worldScaleX() {
            return _worldScaleX;
        }
        private void worldScaleX(float value) {
            _worldScaleX = value;
        }
    }

    @property {
        float worldScaleY() {
            return _worldScaleY;
        }
        private void worldScaleY(float value) {
            _worldScaleY = value;
        }
    }

    void updateWorldTransform(bool flipX, bool flipY) {
        if(parent !is null) {
            worldX = x * parent.m00 + y * parent.m01 + parent.worldX;
            worldY = x * parent.m10 + y * parent.m11 + parent.worldY;
            if(data.inheritScale) {
                worldScaleX = parent.worldScaleX * scaleX;
                worldScaleY = parent.worldScaleY * scaleY;
            } else {
                worldScaleX = scaleX;
                worldScaleY = scaleY;
            }
            worldRotation = data.inheritRotation ? parent.worldRotation + rotation : rotation;
        } else {
            worldX = flipX ? -x : x;
            worldY = flipY ? -y : y;
            worldScaleX = scaleX;
            worldScaleY = scaleY;
            worldRotation = rotation;
        }
        float radians = worldRotation * std.math.PI / 180;
        float cos = std.math.cos(radians);
        float sin = std.math.sin(radians);
        m00 = cos * worldScaleX;
        m10 = sin * worldScaleX;
        m01 = -sin * worldScaleY;
        m11 = cos * worldScaleY;
        if(flipX) {
            m00 = -m00;
            m01 = -m01;
        }
        if(flipY ^ yDown) {
            m10 = -m10;
            m11 = -m11;
        }
    }

    void setToSetupPose() {
        x = data.x;
        y = data.y;
        rotation = data.rotation;
        scaleX = data.scaleX;
        scaleY = data.scaleY;
    }

    override string toString() {
        return data.name;
    }

private:
    BoneData _data;
    Bone _parent;
    float _x, _y;
    float _rotation;
    float _scaleX, _scaleY;
    float _m00, _m01, _m10, _m11;
    float _worldX, _worldY;
    float _worldRotation;
    float _worldScaleX, _worldScaleY;
}