module spine.animation.animation;

import spine.animation.timeline.timeline;
import spine.event.event;
import spine.skeleton.skeleton;
import spine.util.argnull;

export class Animation {

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

    void apply(Skeleton skeleton, float lastTime, float time, bool loop, Event[] events) {
        mixin(ArgNull!skeleton);
        if(loop && duration != 0) {
            time %= duration;
            lastTime %= duration;
        }
        foreach(timeline; timelines)
            timeline.apply(skeleton, lastTime, time, events, 1);
    }

    void mix(Skeleton skeleton, float lastTime, float time, bool loop, Event[] events, float alpha) {
        mixin(ArgNull!skeleton);
        if(loop && duration != 0) {
            time %= duration;
            lastTime %= duration;
        }
        foreach(timeline; timelines)
            timeline.apply(skeleton, lastTime, time, events, alpha);
    }

    static int binarySearch(float[] values, float target, int step=1) {
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

    static int linearSearch(float[] values, float target, int step) {
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