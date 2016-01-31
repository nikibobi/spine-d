module spine.skeleton.data;

import spine.animation.animation;
import spine.bone.data;
import spine.event.data;
import spine.ikconstraint.data;
import spine.skin.skin;
import spine.slot.data;
import spine.util.argnull;

export class SkeletonData {

    @property {
        string name() {
            return _name;
        }
        void name(string value) {
            _name = value;
        }
    }

    @property {
        ref BoneData[] bones() {
            return _bones;
        }
        private void bones(BoneData[] value) {
            _bones = value;
        }
    }

    @property {
        ref SlotData[] slots() {
            return _slots;
        }
        private void slots(SlotData[] value) {
            _slots = value;
        }
    }

    @property {
        ref Skin[] skins() {
            return _skins;
        }
        private void skins(Skin[] value) {
            _skins = value;
        }
    }

    @property {
        Skin defaultSkin() {
            return _defaultSkin;
        }
        void defaultSkin(Skin value) {
            _defaultSkin = value;
        }
    }

    @property {
        ref EventData[] events() {
            return _events;
        }
        void events(EventData[] value) {
            _events = value;
        }
    }

    @property {
        ref Animation[] animations() {
            return _animations;
        }
        void animations(Animation[] value) {
            _animations = value;
        }
    }

    @property {
        ref IkConstraintData[] ikConstraints() {
            return _ikConstraints;
        }
        void ikConstraints(IkConstraintData[] value) {
            _ikConstraints = value;
        }
    }

    @property {
        float width() {
            return _width;
        }
        void width(float value) {
            _width = value;
        }
    }

    @property {
        float height() {
            return _height;
        }
        void height(float value) {
            _height = value;
        }
    }

    @property {
        string ver() {
            return _ver;
        }
        void ver(string value) {
            _ver = value;
        }
    }

    @property {
        string hash() {
            return _hash;
        }
        void hash(string value) {
            _hash = value;
        }
    }

    T find(T)(string name)
    {
        static if(is(T == BoneData))
        {
            return findBone(name);
        }
        static if(is(T == SlotData))
        {
            return findSlot(name);
        }
        static if(is(T == Skin))
        {
            return findSkin(name);
        }
        static if(is(T == EventData))
        {
            return findEvent(name);
        }
        static if(is(T == Animation))
        {
            return findAnimation(name);
        }
        static if(is(T == IkConstraintData))
        {
            return findIkConstraint(name);
        }
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

    Skin findSkin(string skinName) {
        mixin(ArgNull!skinName);
        foreach(skin; skins)
            if(skin.name == skinName)
                return skin;
        return null;
    }

    EventData findEvent(string eventDataName) {
        mixin(ArgNull!eventDataName);
        foreach(eventData; events)
            if(eventData.name == eventDataName)
                return eventData;
        return null;
    }

    Animation findAnimation(string animationName) {
        mixin(ArgNull!animationName);
        foreach(animation; animations)
            if(animation.name == animationName)
                return animation;
        return null;
    }

    IkConstraintData findIkConstraint(string ikConstraintName) {
        mixin(ArgNull!ikConstraintName);
        foreach(ikConstraint; ikConstraints)
            if(ikConstraint.name == ikConstraintName)
                return ikConstraint;
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
    Skin _defaultSkin;
    EventData[] _events;
    Animation[] _animations;
    IkConstraintData[] _ikConstraints;
    float _width, _height;
    string _ver, _hash, _imagesPath;
}