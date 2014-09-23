module spine.attachment.loader;

import spine.attachment.attachment;
import spine.attachment.type;
import spine.skin.skin;

export interface AttachmentLoader {
    //TODO: remove this methid and implement the others
    Attachment NewAttachment(Skin skin, AttachmentType type, string name);

    //TODO: implement newRegionAttachment method
    //TODO: implement newMeshAttachment method
    //TODO: implement newSkinnedMeshAttachment method
    //TODO: implement newBoundingBoxAttachment method
}