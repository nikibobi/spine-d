module spine.animation.timeline.draworder;

import spine.animation.animation;
import spine.animation.timeline.timeline;
import spine.skeleton.skeleton;
import spine.slot.slot;

export class DrawOrderTimeline : Timeline {

    this(int frameCount) {
        _frames.length = frameCount;
        _drawOrders.length = frameCount;
    }

    @property {
        float[] frames() {
            return _frames;
        }
        void frames(float[] value) {
            _frames = value;
        }
    }

    @property {
        int[][] drawOrders() {
            return _drawOrders;
        }
        void drawOrders(int[][] value) {
            _drawOrders = value;
        }
    }

    @property int frameCount() {
        return _frames.length;
    }

    void setFrame(int frameIndex, float time, int[] drawOrder) {
        _frames[frameIndex] = time;
        _drawOrders[frameIndex] = drawOrder;
    }

    void apply(Skeleton skeleton, float time, float alpha) {
        if(time < frames[0])
            return; //time is before last frame

        int frameIndex;
        if(time >= frames[$ - 1]) //time is after last frame
            frameIndex = frames.length - 1;
        else
            frameIndex = Animation.binarySearch(frames, time, 1) - 1;

        Slot[] drawOrder = skeleton.drawOrder;
        Slot[] slots = skeleton.slots;
        int[] drawOrderToSetupIndex = drawOrders[frameIndex];
        if(drawOrderToSetupIndex == null) {
            drawOrder[] = slots[];
        } else {
            for(int i = 0; i < drawOrderToSetupIndex.length; i++)
                drawOrder[i] = slots[drawOrderToSetupIndex[i]];
        }
    }

private:
    float[] _frames;
    int[][] _drawOrders;
}