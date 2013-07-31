module slotdata;

import BoneData;

export class SlotData {
public:
    this(string name, BoneData boneData) {
        if(name is null)
            throw new Exception("name cannot be null.");
        if(boneData is null)
            throw new Exception("boneData cannot be null.");
        this.name = name;
        this.boneData = boneData;
        this.r = 1;
        this.g = 1;
        this.b = 1;
        this.a = 1;
    }

    unittest {
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

    override string toString() {
        return name;
    }
private:
    string _name;
    BoneData _boneData;
    float _r;
    float _g;
    float _b;
    float _a;
    string _attachmentName;
}