module spine.slot.data;

import spine.bone.data;
import spine.util.argnull;

export class SlotData {

    this(string name, BoneData boneData) {
        mixin(ArgNull!name);
        mixin(ArgNull!boneData);
        this.name = name;
        this.boneData = boneData;
        r, g, b, a = 1f;
    }

    unittest {
        debug {
            import std.stdio;
            writeln("Test: SlotData");
        }

        import std.exception;
        assertThrown(new SlotData(null, new BoneData("bone")));
        assertThrown(new SlotData("name", null));

        auto s = new SlotData("slot", new BoneData("bone"));
        assert(s.name == "slot");
        assert(s.boneData.name == "bone");
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
        BoneData boneData() {
            return _boneData;
        }
        private void boneData(BoneData value) {
            _boneData = value;
        }
    }

    @property {
        float r() {
            return _r;
        }
        void r(float value) {
            _r = value;
        }
    }

    @property {
        float g() {
            return _g;
        }
        void g(float value) {
            _g = value;
        }
    }

    @property {
        float b() {
            return _b;
        }
        void b(float value) {
            _b = value;
        }
    }

    @property {
        float a() {
            return _a;
        }
        void a(float value) {
            _a = value;
        }
    }

    @property {
        string attachmentName() {
            return _attachmentName;
        }
        void attachmentName(string value) {
            _attachmentName = value;
        }
    }

    @property {
        bool additiveBlending() {
            return _additiveBlending;
        }
        void additiveBlending(bool value) {
            _additiveBlending = value;
        }
    }

    override string toString() {
        return name;
    }

private:
    string _name;
    BoneData _boneData;
    float _r, _g, _b, _a;
    string _attachmentName;
    bool _additiveBlending;
}