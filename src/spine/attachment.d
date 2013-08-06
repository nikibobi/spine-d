module spine.attachment;

import spine.bone;
import spine.skin;
import spine.atlas;
import spine.util;

import std.conv;
static import std.math;

export:

abstract class Attachment {

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

    override string toString() {
        return name;
    }

private:
    string _name;
}

class RegionAttachment : Attachment {

    enum { X1, Y1, X2, Y2, X3, Y3, X4, Y4 }

    float x;
    float y;
    float scaleX;
    float scaleY;
    float rotation;
    float width;
    float height;

    Object rendererObject;
    float regionOffsetX;
    float regionOffsetY;
    float regionWidth;
    float regionHeight;
    float regionOriginalWidth;
    float regionOriginalHeight;

    this(string name) {
        super(name);
        this.scaleX = 1;
        this.scaleY = 1;
    }

    @property {
        float[8] offset() {
            return _offset;
        }
        private void offset(float[8] value) {
            _offset = value;
        }
    }

    @property {
        float[8] uvs() {
            return _uvs;
        }
        private void uvs(float[8] value) {
            _uvs = value;
        }
    }

    void setUVs(float u, float v, float u2, float v2, bool rotate) {
        if(rotate) {
            uvs[X2] = u;
            uvs[Y2] = v2;
            uvs[X3] = u;
            uvs[Y3] = v;
            uvs[X4] = u2;
            uvs[Y4] = v;
            uvs[X1] = u2;
            uvs[Y1] = v2;
        } else {
            uvs[X1] = u;
            uvs[Y1] = v2;
            uvs[X2] = u;
            uvs[Y2] = v;
            uvs[X3] = u2;
            uvs[Y3] = v;
            uvs[X4] = u2;
            uvs[Y4] = v2;
        }
    }

    void updateOffset() {
        float regionScaleX = width / regionOriginalWidth * scaleX;
        float regionScaleY = height / regionOriginalHeight * scaleY;
        float localX = -width / 2 * scaleX + regionOffsetX * regionScaleX;
        float localY = -height / 2 * scaleY + regionOffsetY * regionScaleY;
        float localX2 = localX + regionWidth * regionScaleX;
        float localY2 = localY + regionHeight * regionScaleY;
        float radians = rotation * std.math.PI / 180;
        float cos = std.math.cos(radians);
        float sin = std.math.sin(radians);
        float localXCos = localX * cos + x;
        float localXSin = localX * sin;
        float localYCos = localY * cos + y;
        float localYSin = localY * sin;
        float localX2Cos = localX2 * cos + x;
        float localX2Sin = localX2 * sin;
        float localY2Cos = localY2 * cos + y;
        float localY2Sin = localY2 * sin;
        offset[X1] = localXCos - localYSin;
        offset[Y1] = localYCos + localXSin;
        offset[X2] = localXCos - localY2Sin;
        offset[Y2] = localY2Cos + localXSin;
        offset[X3] = localX2Cos - localY2Sin;
        offset[Y3] = localY2Cos + localX2Sin;
        offset[X4] = localX2Cos - localYSin;
        offset[Y4] = localYCos + localX2Sin;
    }

    void computeVertices(float x, float y, Bone bone, float[] vertices) {
        x += bone.worldX;
        y += bone.worldY;
        float m00 = bone.m00;
        float m01 = bone.m01;
        float m10 = bone.m10;
        float m11 = bone.m11;
        vertices[X1] = offset[X1] * m00 + offset[Y1] * m01 + x;
        vertices[Y1] = offset[X1] * m10 + offset[Y1] * m11 + y;
        vertices[X2] = offset[X2] * m00 + offset[Y2] * m01 + x;
        vertices[Y2] = offset[X2] * m10 + offset[Y2] * m11 + y;
        vertices[X3] = offset[X3] * m00 + offset[Y3] * m01 + x;
        vertices[Y3] = offset[X3] * m10 + offset[Y3] * m11 + y;
        vertices[X4] = offset[X4] * m00 + offset[Y4] * m01 + x;
        vertices[Y4] = offset[X4] * m10 + offset[Y4] * m11 + y;

    }

private:
    float[8] _offset;
    float[8] _uvs;
}

enum AttachmentType { 
    Region, 
    RegionSequence
}

interface AttachmentLoader {
    Attachment NewAttachment(Skin skin, AttachmentType type, string name);
}

class AtlasAttachmentLoader : AttachmentLoader {

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