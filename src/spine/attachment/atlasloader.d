module spine.attachment.atlasloader;

export class AtlasAttachmentLoader : AttachmentLoader {

    this(Atlas atlas) {
        mixin(ArgNull!atlas);
        _atlas = atlas;
    }

    Attachment NewAttachment(Skin skin, AttachmentType type, string name) {
        switch(type) {
            case AttachmentType.Region:
                AtlasRegion region = _atlas.findRegion(name);
                if(region is null)
                    throw new Exception("Region not found in atlas: "~name~" ("~type.to!string~")");
                RegionAttachment attachment = new RegionAttachment(name);
                attachment.rendererObject = region.page.rendererObject;
                attachment.setUVs(region.u, region.v, region.u2, region.v2, region.rotate);
                attachment.regionOffsetX = region.offsetX;
                attachment.regionOffsetY = region.offsetY;
                attachment.regionWidth = region.width;
                attachment.regionHeight = region.height;
                attachment.regionOriginalWidth = region.originalWidth;
                attachment.regionOriginalHeight = region.originalHeight;
                return attachment;
            default:
                throw new Exception("Unknown attachment type: "~type.to!string);
        }
    }

    private Atlas _atlas;
}