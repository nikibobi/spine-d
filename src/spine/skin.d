module spine.skin;

import spine.attachment;
import spine.slot;
import spine.skeleton;
import spine.util;

export class Skin {

    this(string name) {
        mixin(ArgNull!name);
        this.name = name;
    }

    @property {
        string name() {
            return _name;
        }
        private void name(string value) {
            _name = value;
        }
    }

    void addAttachment(int slotIndex, string name, Attachment attachment) {
        mixin(ArgNull!attachment);
        _attachments[Key(slotIndex, name)] = attachment;
    }

    Attachment getAttachment(int slotIndex, string name) {
        return _attachments[Key(slotIndex, name)];
    }

    void findNamesForSlot(int slotIndex, string[] names) {
        mixin(ArgNull!names);
        foreach(key; _attachments.keys)
            if(key.slotIndex == slotIndex)
                names ~= key.name;
    }

    void findAttachmentsForSlot(int slotIndex, Attachment[] attachments) {
        mixin(ArgNull!attachments);
        foreach(key, value; _attachments)
            if(key.slotIndex == slotIndex)
                attachments ~= value;
    }

    override string toString() {
        return name;
    }

    package void attachAll(Skeleton skeleton, Skin oldSkin) {
        foreach(key, value; oldSkin._attachments) {
            Slot slot = skeleton.slots[key.slotIndex];
            if(slot.attachment == value) {
                Attachment attachment = getAttachment(key.slotIndex, key.name);
                if(attachment !is null)
                    slot.attachment = attachment;
            }
        }
    }

private:
    string _name;
    Attachment[Key] _attachments;

    struct Key {
        int slotIndex;
        string name;

        this(int slotIndex, string name) {
            this.slotIndex = slotIndex;
            this.name = name;
        }

        const hash_t opHash() {
            return slotIndex;
        }

        const bool opEquals(ref const Key other) {
            return this.slotIndex == other.slotIndex && this.name == other.name;
        }
    }
}