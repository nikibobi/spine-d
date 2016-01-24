module spine.slot.slot;

import std.algorithm : countUntil;

import spine.attachment.attachment;
import spine.bone.bone;
import spine.skeleton.skeleton;
import spine.slot.data;
import spine.slot.data;
import spine.util.argnull;

export class Slot {

    this(SlotData data, Bone bone) {
        mixin(ArgNull!data);
        mixin(ArgNull!bone);
        this.data = data;
        this.bone = bone;
        r = 1f;
        g = 1f;
        b = 1f;
        a = 1f;
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
            return bone.skeleton;
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
            if(_attachment == value) return;
            _attachment = value;
            _attachmentTime = skeleton.time;
            _attachmentVerticesCount = 0;
        }
    }

    @property {
        float attachmentTime() {
            return skeleton.time - _attachmentTime;
        }
        void attachmentTime(float value) {
            _attachmentTime = skeleton.time - value;
        }
    }

    @property {
        float[] attachmentVertices() {
            return _attachmentVertices;
        }
        void attachmentVertices(float[] value) {
            _attachmentVertices = value;
        }
    }

    @property {
        int attachmentVerticesCount() {
            return _attachmentVerticesCount;
        }
        void attachmentVerticesCount(int value) {
            _attachmentVerticesCount = value;
        }
    }

    public void setToSetupPose(int slotIndex) {
        r = data.r;
        g = data.g;
        b = data.b;
        a = data.a;
        if (data.attachmentName is null)
            attachment = null;
        else {
            _attachment = null;
            attachment = bone.skeleton.getAttachment(slotIndex, data.attachmentName);
        }
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
    float _r, _g, _b, _a;
    Attachment _attachment;
    float _attachmentTime;
    float[] _attachmentVertices;
    int _attachmentVerticesCount;
}
