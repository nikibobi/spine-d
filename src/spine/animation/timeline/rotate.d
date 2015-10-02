module spine.animation.timeline.rotate;

import spine.animation.animation;
import spine.animation.timeline.curve;
import spine.bone.bone;
import spine.event.event;
import spine.skeleton.skeleton;

export class RotateTimeline : CurveTimeline {

    protected enum int LAST_FRAME_TIME = -2;
    protected enum int FRAME_VALUE = 1;

    this(int frameCount) {
        super(frameCount);
        frames = new float[frameCount * 2];
    }

    @property {
        int boneIndex() {
            return _boneIndex;
        }
        void boneIndex(int value) {
            _boneIndex = value;
        }
    }

    @property {
        float[] frames() {
            return _frames;
        }
        private void frames(float[] value) {
            _frames = value;
        }
    }

    void setFrame(int frameIndex, float time, float angle) {
        frameIndex *= 2;
        frames[frameIndex] = time;
        frames[frameIndex + 1] = angle;
    }

    override void apply(Skeleton skeleton, float lastTime, float time, Event[] events, float alpha) {
        if(time < frames[0])
            return;

        Bone bone = skeleton.bones[boneIndex];
        float amount;

        if(time >= frames[$ - 2]) {
            amount = bone.data.rotation + frames[$ - 1] - bone.rotation;
            while(amount > 180)
                amount -= 360;
            while(amount < -180)
                amount += 360;
            bone.rotation = bone.rotation + amount * alpha;
            return;
        }

        int frameIndex = Animation.binarySearch(frames, time, 2);
        float lastFrameValue = frames[frameIndex - 1];
        float frameTime = frames[frameIndex];
        float percent = 1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime);
        percent = getCurvePercent(frameIndex / 2 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

        amount = frames[frameIndex + FRAME_VALUE] - lastFrameValue;
        while(amount > 180)
            amount -= 360;
        while(amount < -180)
            amount += 360;
        amount = bone.data.rotation + (lastFrameValue + amount * percent) - bone.rotation;
        while(amount > 180)
            amount -= 360;
        while(amount < -180)
            amount += 360;
        bone.rotation = bone.rotation + amount * alpha;
    }

private:
    int _boneIndex;
    float[] _frames;
}