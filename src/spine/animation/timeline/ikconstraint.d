module spine.animation.timeline.ikconstraint;

import spine.animation.animation;
import spine.animation.timeline.curve;
import spine.event.event;
import spine.ikconstraint.ikconstraint;
import spine.skeleton.skeleton;

export class IkConstraintTimeline : CurveTimeline {

    protected enum int PREV_FRAME_TIME = -3;
    protected enum int PREV_FRAME_MIX = -2;
    protected enum int PREV_FRAME_BEND_DIRECTION = -1;
    protected enum int FRAME_MIX = 1;

    this(int frameCount) {
        super(frameCount);
        frames.length = frameCount * 3;
    }

    @property {
        int ikConstraintIndex() {
            return _ikConstraintIndex;
        }
        void ikConstraintIndex(int value) {
            _ikConstraintIndex = value;
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

    void setFrame(int frameIndex, float time, float mix, int bendDirection) {
        frameIndex *= 3;
        frames[frameIndex] = time;
        frames[frameIndex + 1] = mix;
        frames[frameIndex + 2] = bendDirection;
    }

    override void apply(Skeleton skeleton, float lastTime, float time, Event[] firedEvents, float alpha) {
        if(time < frames[0])
            return; // Time is before first frame.

        IkConstraint ikConstraint = skeleton.ikConstraints[ikConstraintIndex];
        if(time >= frames[$ - 3]) { // Time is after last frame.
            ikConstraint.mix = ikConstraint.mix + (frames[$ - 2] - ikConstraint.mix) * alpha;
            ikConstraint.bendDirection = cast(int)frames[$ - 1];
            return;
        }

        // Interpolate between the previous frame and the current frame.
        int frameIndex = Animation.binarySearch(frames, time, 3);
        float prevFrameMix = frames[frameIndex + PREV_FRAME_MIX];
        float frameTime = frames[frameIndex];
        float percent = 1 - (time - frameTime) / (frames[frameIndex + PREV_FRAME_TIME] - frameTime);
        percent = getCurvePercent(frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

        float mix = prevFrameMix + (frames[frameIndex + FRAME_MIX] - prevFrameMix) * percent;
        ikConstraint.mix = ikConstraint.mix + (mix - ikConstraint.mix) * alpha;
        ikConstraint.bendDirection = cast(int)frames[frameIndex + PREV_FRAME_BEND_DIRECTION];
    }

private:
    int _ikConstraintIndex;
    float[] _frames;
}