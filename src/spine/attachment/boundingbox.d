module spine.attachment.boundingbox;

import spine.attachment.attachment;
import spine.bone;

export class BoundingBoxAttachment : Attachment {
    
    this(string name) {
        super(name);
    }

    @property {
        float[] vertices() {
            return _vertices;
        }
        void vertices(float[] value) {
            _vertices = value;
        }
    }

    void computeWorldVertices(Bone bone, float[] worldVertices) {
        float x = bone.skeleton.x + bone.worldX;
        float y = bone.skeleton.y + bone.worldY;
        float m00 = bone.m00;
        float m01 = bone.m01;
        float m10 = bone.m10;
        float m11 = bone.m11;
        float[] vertices = vertices;
        for(int i = 0; i < vertices.length; i += 2) {
            float px = vertices[i];
            float py = vertices[i + 1];
            worldVertices[i] = px * m00 + py * m01 + x;
            worldVertices[i + 1] = px * m10 + py * m11 + y;
        }
    }

private:
    float[] _vertices;
}