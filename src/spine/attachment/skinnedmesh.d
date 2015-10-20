module spine.attachment.skinnedmesh;

import spine.attachment.attachment;
import spine.bone.bone;
import spine.skeleton.skeleton;
import spine.slot.slot;

export class SkinnedMeshAttachment : Attachment {
    
    this(string name) {
        super(name);
        r = 1f;
        g = 1f;
        b = 1f;
        a = 1f;
    }

    @property {
        int hullLength() {
            return _hullLength;
        }
        void hullLength(int value) {
            _hullLength = value;
        }
    }

    @property {
        ref int[] bones() {
            return _bones;
        }
        void bones(int[] value) {
            _bones = value;
        }
    }

    @property {
        ref float[] weights() {
            return _weights;
        }
        void weights(float[] value) {
            _weights = value;
        }
    }

    @property {
        ref float[] regionUVs() {
            return _regionUVs;
        }
        void regionUVs(float[] value) {
            _regionUVs = value;
        }
    }

    @property {
        ref float[] uvs() {
            return _uvs;
        }
        void uvs(float[] value) {
            _uvs = value;
        }
    }

    @property {
        ref int[] triangles() {
            return _triangles;
        }
        void triangles(int[] value) {
            _triangles = value;
        }
    }

    @property {
        float r() {
            return _r;
        }
        void r(float value) {
            _r = value;
        }
    }

    @property {
        float g() {
            return _g;
        }
        void g(float value) {
            _g = value;
        }
    }

    @property {
        float b() {
            return _b;
        }
        void b(float value) {
            _b = value;
        }
    }

    @property {
        float a() {
            return _a;
        }
        void a(float value) {
            _a = value;
        }
    }

    @property {
        string path() {
            return _path;
        }
        void path(string value) {
            _path = value;
        }
    }

    @property {
        Object rendererObject() {
            return _rendererObject;
        }
        void rendererObject(Object value) {
            _rendererObject = value;
        }
    }

    @property {
        float regionU() {
            return _regionU;
        }
        void regionU(float value) {
            _regionU = value;
        }
    }

    @property {
        float regionV() {
            return _regionV;
        }
        void regionV(float value) {
            _regionV = value;
        }
    }

    @property {
        float regionU2() {
            return _regionU2;
        }
        void regionU2(float value) {
            _regionU2 = value;
        }
    }

    @property {
        float regionV2() {
            return _regionV2;
        }
        void regionV2(float value) {
            _regionV2 = value;
        }
    }

    @property {
        bool regionRotate() {
            return _regionRotate;
        }
        void regionRotate(bool value) {
            _regionRotate = value;
        }
    }

    @property {
        float regionOffsetX() {
            return _regionOffsetX;
        }
        void regionOffsetX(float value) {
            _regionOffsetX = value;
        }
    }

    @property {
        float regionOffsetY() {
            return _regionOffsetY;
        }
        void regionOffsetY(float value) {
            _regionOffsetY = value;
        }
    }

    @property {
        float regionWidth() {
            return _regionWidth;
        }
        void regionWidth(float value) {
            _regionWidth = value;
        }
    }

    @property {
        float regionHeight() {
            return _regionHeight;
        }
        void regionHeight(float value) {
            _regionHeight = value;
        }
    }

    @property {
        float regionOriginalWidth() {
            return _regionOriginalWidth;
        }
        void regionOriginalWidth(float value) {
            _regionOriginalWidth = value;
        }
    }

    @property {
        float regionOriginalHeight() {
            return _regionOriginalHeight;
        }
        void regionOriginalHeight(float value) {
            _regionOriginalHeight = value;
        }
    }

    @property {
        ref int[] edges() {
            return _edges;
        }
        void edges(int[] value) {
            _edges = value;
        }
    }

    @property {
        float width() {
            return _width;
        }
        void width(float value) {
            _width = value;
        }
    }

    @property {
        float height() {
            return _height;
        }
        void height(float value) {
            _height = value;
        }
    }

    void updateUVs() {
        float u = regionU, v = regionV, width = regionU2 - regionU, height = regionV2 - regionV;
        if(uvs is null || uvs.length != regionUVs.length)
            uvs.length = regionUVs.length;
        if(regionRotate) {
            for(int i = 0; i < uvs.length; i += 2) {
                uvs[i] = u + regionUVs[i + 1] * width;
                uvs[i + 1] = v + height - regionUVs[i] * height;
            }
        } else {
            for(int i = 0; i < uvs.length; i += 2) {
                uvs[i] = u + regionUVs[i] * width;
                uvs[i + 1] = v + regionUVs[i + 1] * height;
            }
        }
    }

    void computeWorldVertices(Slot slot, float[] worldVertices) {
        Skeleton skeleton = slot.bone.skeleton;
        Bone[] skeletonBones = skeleton.bones;
        float x = skeleton.x, y = skeleton.y;
        if(slot.attachmentVerticesCount == 0) {
            for(int w = 0, v = 0, b = 0; v < bones.length; w += 2) {
                float wx = 0, wy = 0;
                int nn = bones[v++] + v;
                for(; v < nn; v++, b += 3) {
                    Bone bone = skeletonBones[bones[v]];
                    float vx = weights[b], vy = weights[b + 1], weight = weights[b + 2];
                    wx += (vx * bone.m00 + vy * bone.m01 + bone.worldX) * weight;
                    wy += (vx * bone.m10 + vy * bone.m11 + bone.worldY) * weight;
                }
                worldVertices[w] = wx + x;
                worldVertices[w + 1] = wy + y;
            }
        } else {
            float[] ffd = slot.attachmentVertices;
            for(int w = 0, v = 0, b = 0, f = 0; v < bones.length; w += 2) {
                float wx = 0, wy = 0;
                int nn = bones[v++] + v;
                for(; v < nn; v++, b += 3, f += 2) {
                    Bone bone = skeletonBones[bones[v]];
                    float vx = weights[b] + ffd[f], vy = weights[b + 1] + ffd[f + 1], weight = weights[b + 2];
                    wx += (vx * bone.m00 + vy * bone.m01 + bone.worldX) * weight;
                    wy += (vx * bone.m10 + wy * bone.m11 + bone.worldY) * weight;
                }
                worldVertices[w] = wx + x;
                worldVertices[w + 1] = wy + y;
            }
        }
    }

private:
    int[] _bones;
    float[] _weights, _uvs, _regionUVs;
    int[] _triangles;
    float _regionOffsetX, _regionOffsetY, _regionWidth, _regionHeight, _regionOriginalWidth, _regionOriginalHeight;
    float _r, _g, _b, _a;

    int _hullLength;
    string _path;
    Object _rendererObject;
    float _regionU, _regionV, _regionU2, _regionV2;
    bool _regionRotate;
    int[] _edges;
    float _width, _height;
}