module spine.ikconstraint.ikconstraint;

import std.math : acos, atan2, sin, sqrt, PI;

import spine.bone.bone;
import spine.ikconstraint.data;
import spine.skeleton.skeleton;
import spine.util.argnull;

export class IkConstraint {

    this(IkConstraintData data, Skeleton skeleton) {
        mixin(ArgNull!data);
        mixin(ArgNull!skeleton);
        this.data = data;
        this.mix = data.mix;
        this.bendDirection = data.bendDirection;

        bones = new Bone[data.bones.length];
        foreach(i, boneData; data.bones)
            bones[i] = skeleton.findBone(boneData.name);
        target = skeleton.findBone(data.target.name);
    }

    @property {
        IkConstraintData data() {
            return _data;
        }
        private void data(IkConstraintData value) {
            _data = value;
        }
    }

    @property {
        ref Bone[] bones() {
            return _bones;
        }
        private void bones(Bone[] value) {
            _bones = value;
        }
    }

    @property {
        Bone target() {
            return _target;
        }
        void target(Bone value) {
            _target = value;
        }
    }

    @property {
        int bendDirection() {
            return _bendDirection;
        }
        void bendDirection(int value) {
            _bendDirection = value;
        }
    }

    @property {
        float mix() {
            return _mix;
        }
        void mix(float value) {
            _mix = value;
        }
    }

    void apply() {
        final switch(bones.length) {
            case 1:
                apply(bones[0], target.worldX, target.worldY, mix);
                break;
            case 2:
                apply(bones[0], bones[1], target.worldX, target.worldY, bendDirection, mix);
                break;
        }
    }

    override string toString() {
        return data.name;
    }

    static void apply(Bone bone, float targetX, float targetY, float alpha) {
        float parentRotation = (!bone.data.inheritRotation || bone.parent is null) ? 0 : bone.parent.worldRotation;
        float rotation = bone.rotation;
        float rotationIK = atan2(targetY - bone.worldY, targetX - bone.worldX) * radDeg;
        if(bone.worldFlipX != (bone.worldFlipY != Bone.yDown))
            rotationIK = -rotationIK;
        rotationIK -= parentRotation;
        bone.rotationIK = rotation + (rotationIK - rotation) * alpha;
    }

    static void apply(Bone parent, Bone child, float targetX, float targetY, int bendDirection, float alpha) {
        float childRotation = child.rotation, parentRotation = parent.rotation;
        if(alpha == 0) {
            child.rotationIK = childRotation;
            parent.rotationIK = parentRotation;
            return;
        }
        float positionX, positionY;
        Bone parentParent = parent.parent;
        if(parentParent !is null) {
            parentParent.worldToLocal(targetX, targetY, positionX, positionY);
            targetX = (positionX - parent.x) * parentParent.worldScaleX;
            targetY = (positionY - parent.y) * parentParent.worldScaleY;
        } else {
            targetX -= parent.x;
            targetY -= parent.y;
        }
        if(child.parent == parent) {
            positionX = child.x;
            positionY = child.y;
        } else {
            child.parent.localToWorld(child.x, child.y, positionX, positionY);
            parent.worldToLocal(positionX, positionY, positionX, positionY);
        }
        float childX = positionX * parent.worldScaleX, childY = positionY * parent.worldScaleY;
        float offset = atan2(childY, childX);
        float len1 = sqrt(childX * childX + childY * childY), len2 = child.data.length * child.worldScaleX;
        // Based on code by Ryan Juckett with permission: Copyright (c) 2008-2009 Ryan Juckett, http://www.ryanjuckett.com/
        float cosDenom = 2 * len1 * len2;
        if(cosDenom < 0.0001f) {
            child.rotationIK = childRotation + (atan2(targetY, targetX) * radDeg - parentRotation - childRotation) * alpha;
            return;
        }
        float cos = (targetX * targetX + targetY * targetY - len1 * len1 - len2 * len2) / cosDenom;
        if(cos < -1)
            cos = -1;
        else if(cos > 1)
            cos = 1;
        float childAngle = acos(cos) * bendDirection;
        float adjacent = len1 + len2 * cos, opposite = len2 * sin(childAngle);
        float parentAngle = atan2(targetY * adjacent - targetX * opposite, targetX * adjacent + targetY * opposite);
        float rotation = (parentAngle - offset) * radDeg - parentRotation;
        if(rotation > 180)
            rotation -= 360;
        else if(rotation < -180)
            rotation += 360;
        parent.rotationIK = parentRotation + rotation * alpha;
        rotation = (childAngle + offset) * radDeg - childRotation;
        if(rotation > 180)
            rotation -= 360;
        else if(rotation < -180)
            rotation += 360;
        child.rotationIK = childRotation + (rotation + parent.worldRotation - child.parent.worldRotation) * alpha;
    }

private:
    enum float radDeg = 180f / cast(float)PI;

    IkConstraintData _data;
    Bone[] _bones;
    Bone _target;
    int _bendDirection;
    float _mix;
}