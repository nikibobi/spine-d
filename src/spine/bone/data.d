module spine.bone.data;

import spine.util.argnull;

export class BoneData {

    this(string name, BoneData parent = null) {
        mixin(ArgNull!name);
        this.name = name;
        this.parent = parent;
        this.scaleX = 1;
        this.scaleY = 1;
        this.inheritScale = true;
        this.inheritRotation = true;
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
        bool flipX() {
            return _flipX;
        }
        void flipX(bool value) {
            _flipX = value;
        }
    }

    @property {
        bool flipY() {
            return _flipY;
        }
        void flipY(bool value) {
            _flipY = value;
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
    bool _flipX, _flipY;
    bool _inheritScale, _inheritRotation;
}