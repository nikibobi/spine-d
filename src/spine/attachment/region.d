module spine.attachment.region;

import spine.attachment.attachment;
import spine.bone.bone;
static import std.math;

export class RegionAttachment : Attachment {

    enum { X1, Y1, X2, Y2, X3, Y3, X4, Y4 }

    //TODO: maybe make these properties
    float x;
    float y;
    float scaleX;
    float scaleY;
    float rotation;
    float width;
    float height;

    float r, g, b, a;
    string path;
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
        r = 1f;
        g = 1f;
        b = 1f;
        a = 1f;
    }

    @property {
        ref float[8] offset() {
            return _offset;
        }
        private void offset(float[8] value) {
            _offset = value;
        }
    }

    @property {
        ref float[8] uvs() {
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

    void computeWorldVertices(Bone bone, float[] worldVertices) {
        float x = bone.skeleton.x + bone.worldX;
        float y = bone.skeleton.y + bone.worldY;
        float m00 = bone.m00;
        float m01 = bone.m01;
        float m10 = bone.m10;
        float m11 = bone.m11;
        worldVertices[X1] = offset[X1] * m00 + offset[Y1] * m01 + x;
        worldVertices[Y1] = offset[X1] * m10 + offset[Y1] * m11 + y;
        worldVertices[X2] = offset[X2] * m00 + offset[Y2] * m01 + x;
        worldVertices[Y2] = offset[X2] * m10 + offset[Y2] * m11 + y;
        worldVertices[X3] = offset[X3] * m00 + offset[Y3] * m01 + x;
        worldVertices[Y3] = offset[X3] * m10 + offset[Y3] * m11 + y;
        worldVertices[X4] = offset[X4] * m00 + offset[Y4] * m01 + x;
        worldVertices[Y4] = offset[X4] * m10 + offset[Y4] * m11 + y;

    }

private:
    float[8] _offset;
    float[8] _uvs;
}