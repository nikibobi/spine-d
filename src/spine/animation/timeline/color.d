module spine.animation.timeline.color;

import spine.animation.animation;
import spine.animation.timeline.curve;
import spine.event.event;
import spine.skeleton.skeleton;
import spine.slot.slot;

export class ColorTimeline : CurveTimeline {

    protected enum int LAST_FRAME_TIME = -5;
    protected enum { FRAME_R = 1, FRAME_G, FRAME_B, FRAME_A }

    this(int frameCount) {
        super(frameCount);
        frames = new float[frameCount * 5];
    }

    @property {
        int slotIndex() {
            return _slotIndex;
        }
        void slotIndex(int value) {
            _slotIndex = value;
        }
    }

    @property {
        ref float[] frames() {
            return _frames;
        }
        void frames(float[] value) {
            _frames = value;
        }
    }

    void setFrame(int frameIndex, float time, float r, float g, float b, float a) {
        frameIndex *= 5;
        frames[frameIndex] = time;
        frames[frameIndex + 1] = r;
        frames[frameIndex + 2] = g;
        frames[frameIndex + 3] = b;
        frames[frameIndex + 4] = a;
    }

    override void apply(Skeleton skeleton, float lastTime, float time, Event[] events, float alpha) {
        if(time < frames[0])
            return;

        float r, g, b, a;
        if(time >= frames[$ - 5]) {
            r = frames[$ - 4];
            g = frames[$ - 3];
            b = frames[$ - 2];
            a = frames[$ - 1];
        } else {
            int frameIndex = Animation.binarySearch(frames, time, 5);
            float lastFrameR = frames[frameIndex - 4];
            float lastFrameG = frames[frameIndex - 3];
            float lastFrameB = frames[frameIndex - 2];
            float lastFrameA = frames[frameIndex - 1];
            float frameTime = frames[frameIndex];
            float percent = 1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime);
            percent = getCurvePercent(frameIndex / 5 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

            r = lastFrameR + (frames[frameIndex + FRAME_R] - lastFrameR) * percent;
            g = lastFrameG + (frames[frameIndex + FRAME_G] - lastFrameG) * percent;
            b = lastFrameB + (frames[frameIndex + FRAME_B] - lastFrameB) * percent;
            a = lastFrameA + (frames[frameIndex + FRAME_A] - lastFrameA) * percent;
        }
        Slot slot = skeleton.slots[slotIndex];
        if (alpha < 1) {
            slot.r = slot.r + (r - slot.r) * alpha;
            slot.g = slot.g + (g - slot.g) * alpha;
            slot.b = slot.b + (b - slot.b) * alpha;
            slot.a = slot.a + (a - slot.a) * alpha;
        } else {
            slot.r = r;
            slot.g = g;
            slot.b = b;
            slot.a = a;
        }
    }

private:
    int _slotIndex;
    float[] _frames;
}