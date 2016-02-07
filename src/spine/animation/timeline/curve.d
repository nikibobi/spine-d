module spine.animation.timeline.curve;

import spine.animation.timeline.timeline;
import spine.event.event;
import spine.skeleton.skeleton;

export abstract class CurveTimeline : Timeline {

    protected enum float LINEAR = 0, STEPPED = 1, BEZIER = 2;
    protected enum int BEZIER_SEGMENTS = 10;
    protected enum int BEZIER_SIZE = BEZIER_SEGMENTS * 2 - 1;

    this(int frameCount) {
        curves = new float[(frameCount - 1) * BEZIER_SIZE];
		curves[] = 0f;
    }

    private @property {
        float[] curves() {
            return _curves;
        }
        void curves(float[] value) {
            _curves = value;
        }
    }

    @property int frameCount() {
        return curves.length / BEZIER_SIZE + 1;
    }

    abstract void apply(E)(Skeleton skeleton, float lastTime, float time, E events, float alpha);

    void setLinear(int frameIndex) {
        curves[frameIndex * BEZIER_SIZE] = LINEAR;
    }

    void setStepped(int frameIndex) {
        curves[frameIndex * BEZIER_SIZE] = STEPPED;
    }

    void setCurve(int frameIndex, float cx1, float cy1, float cx2, float cy2) {
        float subdiv1 = 1f / BEZIER_SEGMENTS;
        float subdiv2 = subdiv1 * subdiv1;
        float subdiv3 = subdiv2 * subdiv1;
        float pre1 = 3 * subdiv1;
        float pre2 = 3 * subdiv2;
        float pre4 = 6 * subdiv2;
        float pre5 = 6 * subdiv3;
        float tmp1x = -cx1 * 2 + cx2;
        float tmp1y = -cy1 * 2 + cy2;
        float tmp2x = (cx1 - cx2) * 3 + 1;
        float tmp2y = (cy1 - cy2) * 3 + 1;
        float dfx = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv3;
        float dfy = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv3;
        float ddfx = tmp1x * pre4 + tmp2x * pre5;
        float ddfy = tmp1y * pre4 + tmp2y * pre5;
        float dddfx = tmp2x * pre5;
        float dddfy = tmp2y * pre5;

        int i = frameIndex * BEZIER_SIZE;
        curves[i++] = BEZIER;

        float x = dfx;
        float y = dfy;
        for(int n = i + BEZIER_SIZE - 1; i < n; i += 2) {
            curves[i] = x;
            curves[i + 1] = y;
            dfx += ddfx;
            dfy += ddfy;
            ddfx += dddfx;
            ddfy += dddfy;
            x += dfx;
            y += dfy;
        }
    }

    float getCurvePercent(int frameIndex, float percent) {
        int i = frameIndex * BEZIER_SIZE;
        float type = curves[i];
        if(type == LINEAR)
            return percent;
        if(type == STEPPED)
            return 0;
        i++;
        float x = 0;
        for(int start = i, n = i + BEZIER_SIZE - 1; i < n; i += 2) {
            x = curves[i];
            if(x >= percent) {
                float prevX;
                float prevY;
                if(i == start) {
                    prevX = 0;
                    prevY = 0;
                } else {
                    prevX = curves[i - 2];
                    prevY = curves[i - 1];
                }
                return prevY + (curves[i + 1] - prevY) * (percent - prevX) / (x - prevX);
            }
        }
        float y = curves[i - 1];
        return y + (1 - y) * (percent - x) / (1 - x);
    }

    float getCurveType(int frameIndex)
    {
        return curves[frameIndex * BEZIER_SIZE];
    }

    private float[] _curves;
}