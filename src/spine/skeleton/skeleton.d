module spine.skeleton.skeleton;

import spine.attachment.attachment;
import spine.bone.bone;
import spine.ikconstraint.ikconstraint;
import spine.skeleton.data;
import spine.skin.skin;
import spine.slot.slot;
import spine.util.argnull;

export class Skeleton {

    this(SkeletonData data) {
        mixin(ArgNull!data);
        this.data = data;

        bones = new Bone[data.bones.length];
        foreach(i, boneData; data.bones) {
            Bone parent = boneData.parent is null ? null : bones[countUntil(data.bones, boneData.parent)];
            Bone bone = new Bone(boneData, this, parent);
            if(parent !is null)
                parent.children ~= bone;
            bones[i] = bone;
        }

        slots = new Slot[data.slots.length];
        drawOrder = new Slot[data.slots.length];
        foreach(i, slotData; data.slots) {
            Bone bone = bones[countUntil(data.bones, slotData.boneData)];
            Slot slot = new Slot(slotData, bone);
            slots[i] = slot;
            drawOrder[i] = slot;
        }

        ikConstraints = new IkConstraint[data.ikConstraints.length];
        foreach(i, ikConstraintData; data.ikConstraints)
            ikConstraints[i] = new IkConstraint(ikConstraintData, this);
        //TODO: call updateCache();

        r = 1f;
        g = 1f;
        b = 1f;
        a = 1f;
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
        ref Bone[] bones() {
            return _bones;
        }
        private void bones(Bone[] value) {
            _bones = value;
        }
    }

    @property {
        ref Slot[] slots() {
            return _slots;
        }
        private void slots(Slot[] value) {
            _slots = value;
        }
    }

    @property {
        ref Slot[] drawOrder() {
            return _drawOrder;
        }
        private void drawOrder(Slot[] value) {
            _drawOrder = value;
        }
    }

    @property {
        ref IkConstraint[] ikConstraints() {
            return _ikConstraints;
        }
        private void ikConstraints(IkConstraint[] value) {
            _ikConstraints = value;
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
        ref float time() {
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
        foreach(bone; bones) {
            bone.rotationIK = bone.rotation;
            bone.updateWorldTransform();
        }
    }

    void setToSetupPose() {
        setBonesToSetupPose();
        setSlotsToSetupPose();
    }

    void setBonesToSetupPose() {
        foreach(bone; bones)
            bone.setToSetupPose();

        foreach(ikConstraint; ikConstraints) {
            ikConstraint.bendDirection = ikConstraint.data.bendDirection;
            ikConstraint.mix = ikConstraint.data.mix;
        }
    }

    void setSlotsToSetupPose() {
        drawOrder = slots.dup;

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

    Slot findSlot(string slotName) {
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
        if(newSkin !is null) {
            if(skin !is null) {
                newSkin.attachAll(this, skin);
            } else {
                foreach(i, slot; slots) {
                    string name = slot.data.attachmentName;
                    if(name !is null) {
                        Attachment attachment = newSkin.getAttachment(i, name);
                        if(attachment !is null)
                            slot.attachment = attachment;
                    }
                }
            } 
        }
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

    IkConstraint findIkConstraint(string ikConstraintName) {
        mixin(ArgNull!ikConstraintName);
        foreach(ikConstraint; ikConstraints)
            if(ikConstraint.data.name == ikConstraintName)
                return ikConstraint;
        return null;
    }

    void update(float delta) {
        time += delta;
    }

private:
    SkeletonData _data;
    Bone[] _bones;
    Slot[] _slots;
    Slot[] _drawOrder;
    IkConstraint[] _ikConstraints;
    //TODO: add boneCache
    Skin _skin;
    float _r, _g, _b, _a;
    float _time;
    bool _flipX, _flipY;
    float _x, _y;
}
