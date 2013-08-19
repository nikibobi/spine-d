module spine.animation.timeline.translate;

import spine.animation.animation;
import spine.animation.timeline.curve;
import spine.bone.bone;
import spine.skeleton.skeleton;

export class TranslateTimeline : CurveTimeline {

    protected enum int LAST_FRAME_TIME = -3;
    protected enum int FRAME_X = 1;
    protected enum int FRAME_Y = 2;

    this(int frameCount) {
        super(frameCount);
        frames = new float[frameCount * 3];
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

    void setFrame(int frameIndex, float time, float x, float y) {
        frameIndex *= 3;
        frames[frameIndex] = time;
        frames[frameIndex + 1] = x;
        frames[frameIndex + 2] = y;
    }

    override void apply(Skeleton skeleton, float time, float alpha) {
        if(time < frames[0])
            return;

        Bone bone = skeleton.bones[boneIndex];

        if(time >= frames[$ - 3]) {
            bone.x = bone.x + (bone.data.x + frames[$ - 2] - bone.x) * alpha;
            bone.y = bone.y + (bone.data.y + frames[$ - 1] - bone.y) * alpha;
            return;
        }

        int frameIndex = Animation.binarySearch(frames, time, 3);
        float lastFrameX = frames[frameIndex - 2];
        float lastFrameY = frames[frameIndex - 1];
        float frameTime = frames[frameIndex];
        float percent = 1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime);
        percent = getCurvePercent(frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

        bone.x = bone.x + (bone.data.x + lastFrameX + (frames[frameIndex + FRAME_X] - lastFrameX) * percent - bone.x) * alpha;
        bone.y = bone.y + (bone.data.y + lastFrameY + (frames[frameIndex + FRAME_Y] - lastFrameY) * percent - bone.y) * alpha;
    }

private:
    int _boneIndex;
    float[] _frames;
}