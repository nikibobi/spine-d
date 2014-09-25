module spine.skeleton.skeleton;

import spine.attachment.attachment;
import spine.bone.bone;
import spine.skeleton.data;
import spine.skin.skin;
import spine.slot.slot;
import spine.util.argnull;

export class Skeleton {

    this(SkeletonData data) {
        mixin(ArgNull!data);
        this.data = data;

        bones = new Bone[data.bones.length];
        foreach(boneData; data.bones) {
            Bone parent = boneData is null ? null : bones[countUntil(data.bones, boneData.parent)];
            bones = bones~new Bone(boneData, this, parent);
        }

        foreach(b; bones) {
            if(b.parent !is null) {
                b.parent.children = b.parent.children ~ b; 
            }
        }

        slots = new Slot[data.slots.length];
        drawOrder = new Slot[data.slots.length];
        foreach(slotData; data.slots) {
            Bone bone = bones[countUntil(data.bones, slotData.boneData)];
            Slot slot = new Slot(slotData, bone);
            slots = slots~slot;
            drawOrder = drawOrder~slot;
        }

        //TODO: add ik contraints
        //TODO: call updateCache();

        r, g, b, a = 1f;
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

    //TODO: implement updateCache()

    //TODO: change with ik rotation and constraints
    void updateWorldTransform() {
        foreach(bone; bones)
            bone.updateWorldTransform();
    }

    void setToSetupPose() {
        setBonesToSetupPose();
        setSlotsToSetupPose();
    }

    //TODO: add ik constraints
    void setBonesToSetupPose() {
        foreach(bone; bones)
            bone.setToSetupPose();
    }

    //TODO: include draw order changes
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

    //TODO: this has changed
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

    //TODO: implement findIkConstraint(string ikConstraintName)

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
