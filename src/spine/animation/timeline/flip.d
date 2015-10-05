module spine.animation.timeline.flip;

import spine.animation.animation;
import spine.animation.timeline.timeline;
import spine.bone.bone;
import spine.event.event;
import spine.skeleton.skeleton;

export abstract class FlipTimeline : Timeline {
    
    this(int frameCount) {
        frames = new float[frameCount << 1];
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
        ref float[] frames() {
            return _frames;
        }
        void frames(float[] value) {
            _frames = value;
        }
    }

    @property {
        int frameCount() {
            return _frames.length >> 1;
        }
    }

    void setFrame(int frameIndex, float time, bool flip) {
        frameIndex *= 2;
        frames[frameIndex] = time;
        frames[frameIndex + 1] = flip ? 1 : 0;
    }

    void apply(Skeleton skeleton, float lastTime, float time, Event[] firedEvents, float alpha) {
        if(time < frames[0]) {
            if(lastTime > time)
                apply(skeleton, lastTime, cast(float)int.max, null, 0);
            return;
        } else if(lastTime > time) {
            lastTime = -1;
        }

        int frameIndex = (time >= frames[$ - 2] ? frames.length : Animation.binarySearch(frames, time, 2)) - 2;
        if(frames[frameIndex] < lastTime)
            return;

        setFlip(skeleton.bones[boneIndex], frames[frameIndex + 1] != 0);
    }

    abstract protected void setFlip(Bone bone, bool flip);

protected:
    int _boneIndex;
    float[] _frames;
}