module spine.attachment.mesh;

import spine.attachment.attachment;
import spine.bone.bone;
import spine.slot.slot;

extern class MeshAttachment : Attachment {

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
        ref float[] vertices() {
            return _vertices;
        }
        void vertices(float[] value) {
            _vertices = value;
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
        ref Object rendererObject() {
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
        float u = regionU;
        float v = regionV;
        float width = regionU2 - regionU;
        float height = regionV2 - regionV;
        if(uvs is null || uvs.length != regionUVs.length)
            uvs = new float[regionUVs.length];
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
        Bone bone = slot.bone;
        float x = bone.skeleton.x + bone.worldX;
        float y = bone.skeleton.y + bone.worldY;
        float m00 = bone.m00;
        float m01 = bone.m01;
        float m10 = bone.m10;
        float m11 = bone.m11;
        if(slot.attachmentVerticesCount == vertices.length)
            vertices = slot.attachmentVertices;
        for(int i = 0; i < vertices.length; i += 2) {
            float vx = vertices[i];
            float vy = vertices[i + 1];
            worldVertices[i] = vx * m00 + vy * m01 + x;
            worldVertices[i + 1] = vx * m10 + vy * m11 + y;
        }
    }

private:
    float[] _vertices, _uvs, _regionUVs;
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