module spine.attachment.atlasloader;

import std.conv : to;

import spine.atlas.atlas;
import spine.atlas.region;
import spine.attachment.attachment;
import spine.attachment.boundingbox;
import spine.attachment.loader;
import spine.attachment.mesh;
import spine.attachment.region;
import spine.attachment.skinnedmesh;
import spine.attachment.type;
import spine.skin.skin;
import spine.util.argnull;


export class AtlasAttachmentLoader : AttachmentLoader {

    this(Atlas[] atlases) {
        mixin(ArgNull!atlases);
        _atlases = atlases;
    }

    RegionAttachment newRegionAttachment(Skin skin, string name, string path) {
        AtlasRegion region = findRegion(path);
        if(region is null)
            throw new Exception("Region not found in atlas: " ~ path ~ "(region attachment: " ~ name ~ ")");
        RegionAttachment attachment = new RegionAttachment(name);
        attachment.rendererObject = region;
        attachment.setUVs(region.u, region.v, region.u2, region.v2, region.rotate);
        attachment.regionOffsetX = region.offsetX;
        attachment.regionOffsetY = region.offsetY;
        attachment.regionWidth = region.width;
        attachment.regionHeight = region.height;
        attachment.regionOriginalWidth = region.originalWidth;
        attachment.regionOriginalHeight = region.originalHeight;
        return attachment;
    }

    MeshAttachment newMeshAttachment(Skin skin, string name, string path) {
        AtlasRegion region = findRegion(path);
        if(region is null)
            throw new Exception("Region not found in atlas: " ~ path ~ " (mesh attachment: " ~ name ~ ")");
        MeshAttachment attachment = new MeshAttachment(name);
        attachment.rendererObject = region;
        attachment.regionU = region.u;
        attachment.regionV = region.v;
        attachment.regionU2 = region.u2;
        attachment.regionV2 = region.v2;
        attachment.regionRotate = region.rotate;
        attachment.regionOffsetX = region.offsetX;
        attachment.regionOffsetY = region.offsetY;
        attachment.regionWidth = region.width;
        attachment.regionHeight = region.height;
        attachment.regionOriginalWidth = region.originalWidth;
        attachment.regionOriginalHeight = region.originalHeight;
        return attachment;
    }

    SkinnedMeshAttachment newSkinnedMeshAttachment(Skin skin, string name, string path) {
        AtlasRegion region = findRegion(path);
        if(region is null)
            throw new Exception("Region not found in atlas: " ~ path ~ " (skinned mesh attachment: " ~ name ~ ")");
        SkinnedMeshAttachment attachment = new SkinnedMeshAttachment(name);
        attachment.rendererObject = region;
        attachment.regionU = region.u;
        attachment.regionV = region.v;
        attachment.regionU2 = region.u2;
        attachment.regionV2 = region.v2;
        attachment.regionRotate = region.rotate;
        attachment.regionOffsetX = region.offsetX;
        attachment.regionOffsetY = region.offsetY;
        attachment.regionWidth = region.width;
        attachment.regionHeight = region.height;
        attachment.regionOriginalWidth = region.originalWidth;
        attachment.regionOriginalHeight = region.originalHeight;
        return attachment;
    }

    BoundingBoxAttachment newBoundingBoxAttachment(Skin skin, string name) {
        return new BoundingBoxAttachment(name);
    }

    AtlasRegion findRegion(string name) {
        AtlasRegion region;
        for(int i = 0; i < _atlases.length; i++) {
            region = _atlases[i].findRegion(name);
            if(region !is null)
                return region;
        }
        return null;
    }

    private Atlas[] _atlases;
}