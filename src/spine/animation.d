module spine.animation;

import spine.bone;
import spine.slot;
import spine.skeleton;
import spine.util;

import std.range;

export:

class AnimationStateData {

    this(SkeletonData skeletonData) {
        this.skeletonData = skeletonData;
    }

    @property {
        SkeletonData skeletonData() {
            return _skeletonData;
        }
        private void skeletonData(SkeletonData value) {
            _skeletonData = value;
        }
    }

    @property {
        float defaultMix() {
            return _defaultMix;
        }
        void defaultMix(float value) {
            _defaultMix = value;
        }
    }

    void setMix(string fromName, string toName, float duration) {
        Animation from = skeletonData.findAnimation(fromName);
        if(from is null)
            throw new Exception("Animation not found: "~fromName);
        Animation to = skeletonData.findAnimation(toName);
        if(to is null)
            throw new Exception("Animation not found: "~toName);
        setMix(from, to, duration);
    }

    void setMix(Animation from, Animation to, float duration) {
        mixin(ArgNull!from);
        mixin(ArgNull!to);
        _animationToMixTime[Key(from, to)] = duration;
    }

    float getMix(Animation from, Animation to) {
        return _animationToMixTime.get(Key(from, to), defaultMix);
    }

private:
    SkeletonData _skeletonData;
    float[Key] _animationToMixTime;
    float _defaultMix;

    struct Key {
        Animation from;
        Animation to;

        this(Animation from, Animation to) {
            this.from = from;
            this.to = to;
        }

        hash_t opHash() {
            return from.toHash() ^ to.toHash();
        }

        const bool opEquals(ref const Key other) {
            return this.from == other.from && this.to == other.to;
        }
    }
}

class AnimationState {

    this(AnimationStateData data) {
        mixin(ArgNull!data);
        this.data = data;
    }

    @property {
        AnimationStateData data() {
            return _data;
        }
        private void data(AnimationStateData value) {
            _data = value;
        }
    }

    @property {
        Animation animation() {
            return _animation;
        }
        private void animation(Animation value) {
            _animation = value;
        }
    }

    @property {
        ref float time() {
            return _time;
        }
        void time(float value) {
            _time = value;
        }
    }

    @property {
        bool loop() {
            return _loop;
        }
        void loop(bool value) {
            _loop = value;
        }
    }

    void update(float delta) {
        time += delta;
        _previousTime += delta;
        _mixTime += delta;

        if(!_queue.empty) {
            QueueEntry entry = _queue.front;
            if(time >= entry.delay) {
                setAnimationInternal(entry.animation, entry.loop);
                _queue.popFront();
            }
        }
    }

    void apply(Skeleton skeleton) {
        if(animation is null)
            return;
        if(_previous !is null) {
            _previous.apply(skeleton, _previousTime, _previousLoop);
            float alpha = _mixTime / _mixDuration;
            if(alpha >= 1) {
                alpha = 1;
                _previous = null;
            }
            animation.mix(skeleton, time, loop, alpha);
        } else {
            animation.apply(skeleton, time, loop);
        }
    }

    void addAnimation(string animationName, bool loop, float delay = 0) {
        Animation animation = data.skeletonData.findAnimation(animationName);
        if(animation is null)
            throw new Exception("Animation not found: "~animationName);
        addAnimation(animation, loop, delay);
    }

    void addAnimation(Animation animation, bool loop, float delay = 0) {
        if(delay <= 0) {
            Animation previousAnimation = _queue.empty ? this.animation : _queue[$-1].animation;
            if(previousAnimation !is null)
                delay += previousAnimation.duration - data.getMix(previousAnimation, animation);
            else
                delay = 0;
        }
        _queue ~= QueueEntry(animation, loop, delay);
    }

    private void setAnimationInternal(Animation animation, bool loop) {
        _previous = null;
        if(animation !is null && this.animation !is null) {
            _mixDuration = data.getMix(this.animation, animation);
            if(_mixDuration > 0) {
                _mixTime = 0;
                _previous = this.animation;
                _previousTime = this.time;
                _previousLoop = this.loop;
            }
        }
        this.animation = animation;
        this.loop = loop;
        this.time = 0;
    }

    void setAnimation(string animationName, bool loop) {
        Animation animation = data.skeletonData.findAnimation(animationName);
        if(animation is null)
            throw new Exception("Animation not found: "~animationName);
        setAnimation(animation, loop);
    }

    void setAnimation(Animation animation, bool loop) {
        _queue = [];
        setAnimationInternal(animation, loop);
    }

    void clearAnimation() {
        _queue = [];
        _previous = null;
        animation = null;
    }

    bool isComplete() {
        return animation is null || time >= animation.duration;
    }

    override string toString() {
        return animation !is null && animation.name !is null ? animation.name : super.toString();
    }

private:
    AnimationStateData _data;
    Animation _animation;
    float _time;
    bool _loop;
    Animation _previous;
    float _previousTime;
    bool _previousLoop;
    float _mixTime, _mixDuration;
    QueueEntry[] _queue;

    struct QueueEntry {
        Animation animation;
        bool loop;
        float delay;
    }
}

class Animation {

    this(string name, Timeline[] timelines, float duration) {
        mixin(ArgNull!name);
        mixin(ArgNull!timelines);
        this.name = name;
        this.timelines = timelines;
        this.duration = duration;
    }

    @property {
        string name() {
            return _name;
        }
        private void name(string value) {
            _name = value;
        }
    }

    @property {
        Timeline[] timelines() {
            return _timelines;
        }
        void timelines(Timeline[] value) {
            _timelines = value;
        }
    }

    @property {
        float duration() {
            return _duration;
        }
        void duration(float value) {
            _duration = value;
        }
    }

    void apply(Skeleton skeleton, float time, bool loop) {
        mix(skeleton, time, loop, 1);
    }

    void mix(Skeleton skeleton, float time, bool loop, float alpha) {
        mixin(ArgNull!skeleton);
        if(loop && duration)
            time %= duration;
        foreach(timeline; timelines)
            timeline.apply(skeleton, time, alpha);
    }

    package static int binarySearch(float[] values, float target, int step) {
        int low = 0;
        int high = values.length / step - 2;
        if(high == 0)
            return step;
        int current = cast(int)(cast(uint)high >> 1);
        while(true) {
            if(values[(current + 1) * step] <= target)
                low = current + 1;
            else
                high = current;
            if(low == high)
                return (low + 1) * step;
            current = cast(int)(cast(uint)(low + high) >> 1);
        }
    }

    package static int linearSearch(float[] values, float target, int step) {
        for(int i = 0, last = values.length - step; i <= last; i += step)
            if(values[i] > target)
                return i;
        return -1;
    }

    override hash_t toHash() {
        return cast(hash_t)_duration; //TODO: use better hash
    }

private:
    string _name;
    Timeline[] _timelines;
    float _duration;
}

interface Timeline {
    void apply(Skeleton skeleton, float time, float alpha);
}

abstract class CurveTimeline : Timeline {

    protected enum float LINEAR = 0;
    protected enum float STEPPED = -1;
    protected enum int BEZIER_SEGMENTS = 10;

    this(int frameCount) {
        _curves = new float[(frameCount - 1) * 6];
    }

    @property int frameCount() {
        return _curves.length / 6 + 1;
    }

    abstract void apply(Skeleton skeleton, float time, float alpha);

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

class RotateTimeline : CurveTimeline {

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

    override void apply(Skeleton skeleton, float time, float alpha) {
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

class TranslateTimeline : CurveTimeline {

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

class ScaleTimeline : TranslateTimeline {

    this(int frameCount) {
        super(frameCount);
    }

    override void apply(Skeleton skeleton, float time, float alpha) {
        if(time < frames[0])
            return;

        Bone bone = skeleton.bones[boneIndex];
        if(time >= frames[$ - 3]) {
            bone.scaleX = bone.scaleX + (bone.data.scaleX - 1 + frames[$ - 2] - bone.scaleX) * alpha;
            bone.scaleY = bone.scaleY + (bone.data.scaleY - 1 + frames[$ - 1] - bone.scaleY) * alpha;
            return;
        }

        int frameIndex = Animation.binarySearch(frames, time, 3);
        float lastFrameX = frames[frameIndex - 2];
        float lastFrameY = frames[frameIndex - 1];
        float frameTime = frames[frameIndex];
        float percent = 1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime);
        percent = getCurvePercent(frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

        bone.scaleX = bone.scaleX + (bone.data.scaleX - 1 + lastFrameX + (frames[frameIndex + FRAME_X] - lastFrameX) * percent - bone.scaleX) * alpha;
        bone.scaleY = bone.scaleY + (bone.data.scaleY - 1 + lastFrameY + (frames[frameIndex + FRAME_Y] - lastFrameY) * percent - bone.scaleY) * alpha;
    }
}

class ColorTimeline : CurveTimeline {

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
        float[] frames() {
            return _frames;
        }
        private void frames(float[] value) {
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

    override void apply(Skeleton skeleton, float time, float alpha) {
        if(time < frames[0])
            return;

        Slot slot = skeleton.slots[slotIndex];

        if(time >= frames[$ - 5]) {
            slot.r = frames[$ - 4];
            slot.g = frames[$ - 3];
            slot.b = frames[$ - 2];
            slot.a = frames[$ - 1];
            return;
        }

        int frameIndex = Animation.binarySearch(frames, time, 5);
        float lastFrameR = frames[frameIndex - 4];
        float lastFrameG = frames[frameIndex - 3];
        float lastFrameB = frames[frameIndex - 2];
        float lastFrameA = frames[frameIndex - 1];
        float frameTime = frames[frameIndex];
        float percent = 1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime);
        percent = getCurvePercent(frameIndex / 5 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

        float r = lastFrameR + (frames[frameIndex + FRAME_R] - lastFrameR) * percent;
        float g = lastFrameG + (frames[frameIndex + FRAME_G] - lastFrameG) * percent;
        float b = lastFrameB + (frames[frameIndex + FRAME_B] - lastFrameB) * percent;
        float a = lastFrameA + (frames[frameIndex + FRAME_A] - lastFrameA) * percent;
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

class AttachmentTimeline : Timeline {

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

    void setFrame(int frameIndex, float time, string attachmentName) {
        frames[frameIndex] = time;
        attachmentNames[frameIndex] = attachmentName;
    }

    void apply(Skeleton skeleton, float time, float alpha) {
        if(time < frames[0])
            return;

        int frameIndex;
        if(time >= frames[$ - 1])
            frameIndex = frames.length - 1;
        else
            frameIndex = Animation.binarySearch(frames, time, 1) - 1;

        string attachmentName = attachmentNames[frameIndex];
        skeleton.slots[slotIndex].attachment = attachmentName == null ? null : skeleton.getAttachment(slotIndex, attachmentName);
    }

private:
    int _slotIndex;
    float[] _frames;
    string[] _attachmentNames;
}