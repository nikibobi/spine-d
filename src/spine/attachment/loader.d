module spine.attachment.loader;

import spine.attachment.attachment;
import spine.attachment.type;
import spine.skin.skin;

export interface AttachmentLoader {
    Attachment NewAttachment(Skin skin, AttachmentType type, string name);
}