module spine.bone.bone;

static import std.math;

import spine.bone.data;
import spine.skeleton.skeleton;
import spine.util.argnull;

export class Bone {

    static bool yDown;

    this(BoneData data, Skeleton skeleton, Bone parent = null) {
        mixin(ArgNull!data);
        this.data = data;
        this.skeleton = skeleton;
        this.parent = parent;
        setToSetupPose();        
    }

    @property {
        BoneData data() {
            return _data;
        }
        private void data(BoneData value) {
            _data = value;
        }
    }

    @property {
        Skeleton skeleton() {
            return _skeleton;
        }
        private void skeleton(Skeleton value) {
            _skeleton = value;
        }
    }

    @property {
        Bone parent() {
            return _parent;
        }
        private void parent(Bone value) {
            _parent = value;
        }
    }

    @property {
        Bone[] children() {
            return _children;
        }
        public void children(Bone[] value) {
            _children = value;
        }
    }

    @property {
        float x() {
            return _x;
        }
        void x(float value) {
            _x = value;
        }
    }

    @property {
        float y() {
            return _y;
        }
        void y(float value) {
            _y = value;
        }
    }

    @property {
        float rotation() {
            return _rotation;
        }
        void rotation(float value) {
            _rotation = value;
        }
    }

    @property {
        float rotationIK() {
            return _rotationIK;
        }
        void rotationIK(float value) {
            _rotationIK = value;
        }
    }

    @property {
        float scaleX() {
            return _scaleX;
        }
        void scaleX(float value) {
            _scaleX = value;
        }
    }

    @property {
        float scaleY() {
            return _scaleY;
        }
        void scaleY(float value) {
            _scaleY = value;
        }
    }

    @property {
        float m00() {
            return _m00;
        }
        private void m00(float value) {
            _m00 = value;
        }
    }

    @property {
        float m01() {
            return _m01;
        }
        private void m01(float value) {
            _m01 = value;
        }
    }

    @property {
        float m10() {
            return _m10;
        }
        private void m10(float value) {
            _m10 = value;
        }
    }

    @property {
        float m11() {
            return _m11;
        }
        private void m11(float value) {
            _m11 = value;
        }
    }

    @property {
        float worldX() {
            return _worldX;
        }
        private void worldX(float value) {
            _worldX = value;
        }
    }

    @property {
        float worldY() {
            return _worldY;
        }
        private void worldY(float value) {
            _worldY = value;
        }
    }

    @property {
        float worldRotation() {
            return _worldRotation;
        }
        private void worldRotation(float value) {
            _worldRotation = value;
        }
    }

    @property {
        float worldScaleX() {
            return _worldScaleX;
        }
        private void worldScaleX(float value) {
            _worldScaleX = value;
        }
    }

    @property {
        float worldScaleY() {
            return _worldScaleY;
        }
        private void worldScaleY(float value) {
            _worldScaleY = value;
        }
    }

    void updateWorldTransform() {
        if(parent !is null) {
            worldX = x * parent.m00 + y * parent.m01 + parent.worldX;
            worldY = x * parent.m10 + y * parent.m11 + parent.worldY;
            if(data.inheritScale) {
                worldScaleX = parent.worldScaleX * scaleX;
                worldScaleY = parent.worldScaleY * scaleY;
            } else {
                worldScaleX = scaleX;
                worldScaleY = scaleY;
            }
            worldRotation = data.inheritRotation ? parent.worldRotation + rotationIK : rotationIK;
        } else {
            worldX = skeleton.flipX ? -x : x;
            worldY = skeleton.flipY != yDown ? -y : y;
            worldScaleX = scaleX;
            worldScaleY = scaleY;
            worldRotation = rotationIK;
        }
        float radians = worldRotation * std.math.PI / 180;
        float cos = std.math.cos(radians);
        float sin = std.math.sin(radians);

        if(skeleton.flipX) {
            m00 = -cos * worldScaleX;
            m01 = sin * worldScaleY;
        } else {
            m00 = cos * worldScaleX;
            m01 = -sin * worldScaleY;
        }
        if (skeleton.flipY != yDown) {
            m10 = -sin * worldScaleX;
            m11 = -cos * worldScaleY;
        } else {
            m10 = sin * worldScaleX;
            m11 = cos * worldScaleY;
        }
    }

    void setToSetupPose() {
        x = data.x;
        y = data.y;
        rotation = data.rotation;
        rotationIK = rotation;
        scaleX = data.scaleX;
        scaleY = data.scaleY;
    }

    void worldToLocal(float worldX, float worldY, out float localX, out float localY) {
        float dx = worldX - this.worldX;
        float dy = worldY - this.worldY;
        if (skeleton.flipX != (skeleton.flipY != yDown)) {
            m00 = m00 * -1;
            m11 = m11 * -1;
        }
        float invDet = 1 / (m00 * m11 - m01 * m10);
        localX = (dx * m00 * invDet - dy * m01 * invDet);
        localY = (dy * m11 * invDet - dx * m10 * invDet);
    }

    void localToWorld(float localX, float localY, out float worldX, out float worldY) {
        worldX = localX * m00 + localY * m01 + this.worldX;
        worldY = localX * m10 + localY * m11 + this.worldY;
    }

    override string toString() {
        return data.name;
    }

private:
    BoneData _data;
    Skeleton _skeleton;
    Bone _parent;
    Bone[] _children;
    float _x, _y;
    float _rotation, _rotationIK;
    float _scaleX, _scaleY;
    float _m00, _m01, _m10, _m11;
    float _worldX, _worldY;
    float _worldRotation;
    float _worldScaleX, _worldScaleY;
}