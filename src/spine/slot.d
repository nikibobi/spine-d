module spine.slot;

import spine.attachment;
import spine.bone;
import spine.skeleton;
import spine.util;

import std.algorithm;

export:

class SlotData {

    this(string name, BoneData boneData) {
        mixin(ArgNull!name);
        mixin(ArgNull!boneData);
        this.name = name;
        this.boneData = boneData;

        r,g,b,a = 1;
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

    override string toString() {
        return name;
    }

private:
    string _name;
    BoneData _boneData;
    float _r, _g, _b, _a;
    string _attachmentName;
}

class Slot {

    this(SlotData data, Skeleton skeleton, Bone bone) {
        mixin(ArgNull!data);
        mixin(ArgNull!skeleton);
        mixin(ArgNull!bone);
        this.data = data;
        this.skeleton = skeleton;
        this.bone = bone;
        setToSetupPose();
    }

    @property {
        SlotData data() {
            return _data;
        }
        private void data(SlotData value) {
            _data = value;
        }
    }

    @property {
        Bone bone() {
            return _bone;
        }
        private void bone(Bone value) {
            _bone = value;
        }
    }

    @property {
        Skeleton skeleton() {
            return _skeleton;
        }
        private void skeleton(Skeleton value) {
            _skeleton = value;
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
        Attachment attachment() {
            return _attachment;
        }
        void attachment(Attachment value) {
            _attachment = value;
            _attachmentTime = skeleton.time;
        }
    }

    @property {
        float attachmentTime() {
            return _attachmentTime;
        }
        void attachmentTime(float value) {
            _attachmentTime = skeleton.time - value;
        }
    }

    package void setToSetupPose(int slotIndex) {
        r = data.r;
        g = data.g;
        b = data.b;
        a = data.a;
        attachment = data.attachmentName is null ? null : skeleton.getAttachment(slotIndex, data.attachmentName);
    }

    void setToSetupPose() {
        setToSetupPose(countUntil(skeleton.data.slots, data));
    }

    override string toString() {
        return data.name;
    }

private:
    SlotData _data;
    Bone _bone;
    Skeleton _skeleton;
    float _r, _g, _b, _a;
    Attachment _attachment;
    float _attachmentTime;
}
