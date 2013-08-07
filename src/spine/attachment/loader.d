module spine.attachment.loader;

export interface AttachmentLoader {
    Attachment NewAttachment(Skin skin, AttachmentType type, string name);
}