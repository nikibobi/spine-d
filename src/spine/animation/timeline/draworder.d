module spine.animation.timeline.draworder;

import spine.animation.animation;
import spine.animation.timeline.timeline;
import spine.event.event;
import spine.skeleton.skeleton;
import spine.slot.slot;

export class DrawOrderTimeline : Timeline {

    this(int frameCount) {
        frames = new float[frameCount];
        drawOrders = new int[][frameCount];
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
        ref int[][] drawOrders() {
            return _drawOrders;
        }
        void drawOrders(int[][] value) {
            _drawOrders = value;
        }
    }

    @property int frameCount() {
        return frames.length;
    }

    void setFrame(int frameIndex, float time, int[] drawOrder) {
        frames[frameIndex] = time;
        drawOrders[frameIndex] = drawOrder;
    }

    void apply(Skeleton skeleton, float lastTime, float time, Event[] events, float alpha) {
        if(time < frames[0])
            return; //time is before last frame

        int frameIndex;
        if(time >= frames[$ - 1]) //time is after last frame
            frameIndex = frames.length - 1;
        else
            frameIndex = Animation.binarySearch(frames, time) - 1;

        int[] drawOrderToSetupIndex = drawOrders[frameIndex];
        if(drawOrderToSetupIndex is null) {
            skeleton.drawOrder[] = skeleton.slots[];
        } else {
            for(int i = 0; i < drawOrderToSetupIndex.length; i++) {
                skeleton.drawOrder[i] = skeleton.slots[drawOrderToSetupIndex[i]];
            }
        }
    }

private:
    float[] _frames;
    int[][] _drawOrders;
}