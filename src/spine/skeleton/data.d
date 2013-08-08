module spine.skeleton.data;

export class SkeletonData {

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