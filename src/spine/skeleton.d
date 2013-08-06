module spine.skeleton;

import spine.attachment;
import spine.slot;
import spine.bone;
import spine.skin;
import spine.animation;
import spine.util;

import std.algorithm;

export:

class SkeletonJson {
    //TODO: implement using std.json;
}

class SkeletonData {

    Skin defaultSkin;

    @property {
        string name() {
            return _name;
        }
        void name(string value) {
            _name = value;
        }
    }

    @property {
        BoneData[] bones() {
            return _bones;
        }
        private void bones(BoneData[] value) {
            _bones = value;
        }
    }

    @property {
        SlotData[] slots() {
            return _slots;
        }
        private void slots(SlotData[] value) {
            _slots = value;
        }
    }

    @property {
        Skin[] skins() {
            return _skins;
        }
        private void skins(Skin[] value) {
            _skins = value;
        }
    }

    @property {
        Animation[] animations() {
            return _animations;
        }
        private void animations(Animation[] value) {
            _animations = value;
        }
    }

    void addBone(BoneData bone) {
        mixin(ArgNull!bone);
        bones = bones~bone;
    }

    BoneData findBone(string boneName) {
        mixin(ArgNull!boneName);
        foreach(bone; bones)
            if(bone.name == boneName)
                return bone;
        return null;
    }

    int findBoneIndex(string boneName) {
        mixin(ArgNull!boneName);
        foreach(i, bone; bones)
            if(bone.name == boneName)
                return i;
        return -1;
    }

    void addSlot(SlotData slot) {
        mixin(ArgNull!slot);
        slots = slots~slot;
    }

    SlotData findSlot(string slotName) {
        mixin(ArgNull!slotName);
        foreach(slot; slots)
            if(slot.name == slotName)
                return slot;
        return null;
    }

    int findSlotIndex(string slotName) {
        mixin(ArgNull!slotName);
        foreach(i, slot; slots)
            if(slot.name == slotName)
                return i;
        return -1;
    }

    void addSkin(Skin skin) {
        mixin(ArgNull!skin);
        skins = skins~skin;
    }

    Skin findSkin(string skinName) {
        mixin(ArgNull!skinName);
        foreach(skin; skins)
            if(skin.name == skinName)
                return skin;
        return null;
    }

    void addAnimation(Animation animation) {
        mixin(ArgNull!animation);
        animations = animations~animation;
    }

    Animation findAnimation(string animationName) {
        mixin(ArgNull!animationName);
        foreach(animation; animations)
            if(animation.name == animationName)
                return animation;
        return null;
    }

    override string toString() {
        return name !is null ? name : super.toString();
    }

private:
    string _name;
    BoneData[] _bones;
    SlotData[] _slots;
    Skin[] _skins;
    Animation[] _animations;
}

class Skeleton {

    this(SkeletonData data) {
        mixin(ArgNull!data);
        this.data = data;

        bones = new Bone[data.bones.length];
        foreach(boneData; data.bones) {
            Bone parent = boneData is null ? null : bones[countUntil(data.bones, boneData.parent)];
            bones = bones~new Bone(boneData, parent);
        }

        slots = new Slot[data.slots.length];
        drawOrder = new Slot[data.slots.length];
        foreach(slotData; data.slots) {
            Bone bone = bones[countUntil(data.bones, slotData.boneData)];
            Slot slot = new Slot(slotData, this, bone);
            slots = slots~slot;
            drawOrder = drawOrder~slot;
        }

        //TODO: fix strange error: not a propertsy 'b'
        r = g = b = a = 1f;
    }

    @property {
        SkeletonData data() {
            return _data;
        }
        private void data(SkeletonData value) {
            _data = value;
        }
    }

    @property {
        Bone[] bones() {
            return _bones;
        }
        private void bones(Bone[] value) {
            _bones = value;
        }
    }

    @property {
        Slot[] slots() {
            return _slots;
        }
        private void slots(Slot[] value) {
            _slots = value;
        }
    }

    @property {
        Slot[] drawOrder() {
            return _drawOrder;
        }
        private void drawOrder(Slot[] value) {
            _drawOrder = value;
        }
    }

    @property {
        Skin skin() {
            return _skin;
        }
        private void skin(Skin value) {
            _skin = value;
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
        float time() {
            return _time;
        }
        void time(float value) {
            _time = value;
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
        Bone rootBone() {
            return bones.length == 0 ? null : bones[0];
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

    void updateWorldTransform() {
        foreach(bone; bones)
            bone.updateWorldTransform(flipX, flipY);
    }

    void setToSetupPose() {
        setBonesToSetupPose();
        setSlotsToSetupPose();
    }

    void setBonesToSetupPose() {
        foreach(bone; bones)
            bone.setToSetupPose();
    }

    void setSlotsToSetupPose() {
        foreach(i, slot; slots)
            slot.setToSetupPose(i);
    }

    Bone findBone(string boneName) {
        mixin(ArgNull!boneName);
        foreach(bone; bones)
            if(bone.data.name == boneName)
                return bone;
        return null;
    }

    int findBoneIndex(string boneName) {
        mixin(ArgNull!boneName);
        foreach(i, bone; bones)
            if(bone.data.name == boneName)
                return i;
        return -1;
    }

    Slot findBone(string slotName) {
        mixin(ArgNull!slotName);
        foreach(slot; slots)
            if(slot.data.name == slotName)
                return slot;
        return null;
    }

    int findSlotIndex(string slotName) {
        mixin(ArgNull!slotName);
        foreach(i, slot; slots)
            if(slot.data.name == slotName)
                return i;
        return -1;
    }

    void setSkin(string skinName) {
        Skin skin = data.findSkin(skinName);
        if(skin is null)
            throw new Exception("Skin not found: "~skinName);
        setSkin(skin);
    }

    void setSkin(Skin newSkin) {
        if(skin !is null && newSkin !is null)
            newSkin.attachAll(this, skin);
        skin = newSkin;
    }

    Attachment getAttachment(string slotName, string attachmentName) {
        return getAttachment(data.findSlotIndex(slotName), attachmentName);
    }

    Attachment getAttachment(int slotIndex, string attachmentName) {
        mixin(ArgNull!attachmentName);
        if(skin !is null) {
            Attachment attachment = skin.getAttachment(slotIndex, attachmentName);
            if(attachment !is null)
                return attachment;
        }
        if(data.defaultSkin !is null)
            return data.defaultSkin.getAttachment(slotIndex, attachmentName);
        return null;
    }

    void setAttachment(string slotName, string attachmentName) {
        mixin(ArgNull!slotName);
        foreach(i, slot; slots) {
            if(slot.data.name == slotName) {
                Attachment attachment;
                if(attachmentName !is null) {
                    attachment = getAttachment(i, attachmentName);
                    if(attachment is null)
                        throw new Exception("Attachment not found: "~attachmentName~", for slot: "~slotName);
                }
                slot.attachment = attachment;
                return;
            }
        }
        throw new Exception("Slot not found: "~slotName);
    }

    void update(float delta) {
        time = time + delta;
    }

private:
    SkeletonData _data;
    Bone[] _bones;
    Slot[] _slots;
    Slot[] _drawOrder;
    Skin _skin;
    float _r, _g, _b, _a;
    float _time;
    bool _flipX, _flipY;
    float _x, _y;
}