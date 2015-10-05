module spine.animation.timeline.attachment;

import spine.animation.animation;
import spine.event.event;
import spine.animation.timeline.timeline;
import spine.skeleton.skeleton;

export class AttachmentTimeline : Timeline {

    this(int frameCount) {
        frames = new float[frameCount];
        attachmentNames = new string[frameCount];
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
        float[] frames() {
            return _frames;
        }
        private void frames(float[] value) {
            _frames = value;
        }
    }

    @property {
        string[] attachmentNames() {
            return _attachmentNames;
        }
        private void attachmentNames(string[] value) {
            _attachmentNames = value;
        }
    }

    @property {
        int frameCount() {
            return frames.length;
        }
    }

    void setFrame(int frameIndex, float time, string attachmentName) {
        frames[frameIndex] = time;
        attachmentNames[frameIndex] = attachmentName;
    }

    void apply(Skeleton skeleton, float lastTime, float time, Event[] events, float alpha) {
        if(time < frames[0]) {
            if(lastTime > time)
                apply(skeleton, lastTime, float.max, null, 0);
            return;
        } else if(lastTime > time) {
            lastTime = -1;
        }

        int frameIndex = (time >= frames[$ - 1] ? frames.length - 1 : Animation.binarySearch(frames, time) - 1);
        if(frames[frameIndex] < lastTime)
            return;

        string attachmentName = attachmentNames[frameIndex];
        skeleton.slots[slotIndex].attachment = attachmentName is null ? null : skeleton.getAttachment(slotIndex, attachmentName);
    }

private:
    int _slotIndex;
    float[] _frames;
    string[] _attachmentNames;
}