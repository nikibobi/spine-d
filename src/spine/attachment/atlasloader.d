module spine.attachment.atlasloader;

import std.conv : to;

import spine.atlas.atlas;
import spine.atlas.region;
import spine.attachment.attachment;
import spine.attachment.boundingbox;
import spine.attachment.loader;
import spine.attachment.region;
import spine.attachment.type;
import spine.skin.skin;
import spine.util.argnull;


export class AtlasAttachmentLoader : AttachmentLoader {

    this(Atlas atlas) {
        mixin(ArgNull!atlas);
        _atlas = atlas;
    }

    //TODO: implement the new AttachmentLoader

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
            case AttachmentType.BoundingBox:
                return new BoundingBoxAttachment(name);
            default:
                throw new Exception("Unknown attachment type: "~type.to!string);
        }
    }

    private Atlas _atlas;
}