module spine.skin.skin;

import spine.attachment.attachment;
import spine.skeleton.skeleton;
import spine.slot.slot;
import spine.util.argnull;

export class Skin {

    this(string name) {
        mixin(ArgNull!name);
        this.name = name;
    }

    //TODO: add unittest

    @property {
        string name() {
            return _name;
        }
        private void name(string value) {
            _name = value;
        }
    }

    private @property {
        ref Attachment[Key] attachments() {
            return _attachments;
        }
        void attachments(Attachment[Key] value) {
            _attachments = value;
        }
    }

    void addAttachment(int slotIndex, string name, Attachment attachment) {
        mixin(ArgNull!attachment);
        attachments[Key(slotIndex, name)] = attachment;
    }

    Attachment getAttachment(int slotIndex, string name) {
        if(Key(slotIndex, name) in attachments)
            return attachments[Key(slotIndex, name)];
        return null;
    }

    void findNamesForSlot(int slotIndex, string[] names) {
        mixin(ArgNull!names);
        foreach(key; attachments.keys)
            if(key.slotIndex == slotIndex)
                names ~= key.name;
    }

    void findAttachmentsForSlot(int slotIndex, Attachment[] attachments) {
        mixin(ArgNull!attachments);
        foreach(key, value; this.attachments)
            if(key.slotIndex == slotIndex)
                attachments ~= value;
    }

    override string toString() {
        return name;
    }

    void attachAll(Skeleton skeleton, Skin oldSkin) {
        foreach(key, value; oldSkin.attachments) {
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

        hash_t opHash() {
            return slotIndex;
        }

        const bool opEquals(ref const Key other) {
            return this.slotIndex == other.slotIndex && this.name == other.name;
        }
    }
}