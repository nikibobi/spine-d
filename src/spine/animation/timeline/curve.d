module spine.animation.timeline.curve;

import spine.animation.timeline.timeline;
import spine.event.event;
import spine.skeleton.skeleton;

export abstract class CurveTimeline : Timeline {

    protected enum float LINEAR = 0;
    protected enum float STEPPED = -1;
    protected enum int BEZIER_SEGMENTS = 10;

    this(int frameCount) {
        _curves = new float[(frameCount - 1) * 6];
		_curves[] = 0f;
    }

    @property int frameCount() {
        return _curves.length / 6 + 1;
    }

    abstract void apply(Skeleton skeleton, float lastTime, float time, Event[] events, float alpha);

    void setLinear(int frameIndex) {
        _curves[frameIndex * 6] = LINEAR;
    }

    void setStepped(int frameIndex) {
        _curves[frameIndex * 6] = STEPPED;
    }

    void setCurve(int frameIndex, float cx1, float cy1, float cx2, float cy2) {
        float subdiv_step = 1f / BEZIER_SEGMENTS;
        float subdiv_step2 = subdiv_step * subdiv_step;
        float subdiv_step3 = subdiv_step2 * subdiv_step;
        float pre1 = 3 * subdiv_step;
        float pre2 = 3 * subdiv_step2;
        float pre4 = 6 * subdiv_step2;
        float pre5 = 6 * subdiv_step3;
        float tmp1x = -cx1 * 2 + cx2;
        float tmp1y = -cy1 * 2 + cy2;
        float tmp2x = (cx1 - cx2) * 3 + 1;
        float tmp2y = (cy1 - cy2) * 3 + 1;
        int i = frameIndex * 6;
        _curves[i] = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv_step3;
        _curves[i + 1] = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv_step3;
        _curves[i + 2] = tmp1x * pre4 + tmp2x * pre5;
        _curves[i + 3] = tmp1y * pre4 + tmp2y * pre5;
        _curves[i + 4] = tmp2x * pre5;
        _curves[i + 5] = tmp2y * pre5;
    }

    float getCurvePercent(int frameIndex, float percent) {
        int curveIndex = frameIndex * 6;
        float dfx = _curves[curveIndex];
        if(dfx == LINEAR)
            return percent;
        if(dfx == STEPPED)
            return 0;
        float dfy = _curves[curveIndex + 1];
        float ddfx = _curves[curveIndex + 2];
        float ddfy = _curves[curveIndex + 3];
        float dddfx = _curves[curveIndex + 4];
        float dddfy = _curves[curveIndex + 5];
        float x = dfx, y = dfy;
        int i = BEZIER_SEGMENTS - 2;
        while(true) {
            if(x >= percent) {
                float lastX = x - dfx;
                float lastY = y - dfy;
                return lastY + (y - lastY) * (percent - lastX) / (x - lastX);
            }
            if(i == 0)
                break;
            i--;
            dfx += ddfx;
            dfy += ddfy;
            ddfx += dddfx;
            ddfy += dddfy;
            x += dfx;
            y += dfy;
        }
        return y + (1 - y) * (percent - x) / (1 - x);
    }

    private float[] _curves;
}