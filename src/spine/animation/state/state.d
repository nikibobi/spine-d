module spine.animation.state.state;

import std.array;
import std.range;
import std.signals;

import spine.animation.animation;
import spine.animation.state.data;
import spine.animation.state.trackentry;
import spine.event.event;
import spine.skeleton.skeleton;
import spine.util.argnull;

export class AnimationState {

    this(AnimationStateData data) {
        mixin(ArgNull!data);
        this.data = data;
        this.timeScale = 1f;
    }

    mixin Signal!(AnimationState, int) start;
    mixin Signal!(AnimationState, int) end;
    mixin Signal!(AnimationState, int, Event) event;
    mixin Signal!(AnimationState, int, int) complete;

    @property {
        AnimationStateData data() {
            return _data;
        }
        private void data(AnimationStateData value) {
            _data = value;
        }
    }

    @property {
        float timeScale() {
            return _timeScale;
        }
        void timeScale(float value) {
            _timeScale = value;
        }
    }

    void update(float delta) {
        delta *= timeScale;
        for(int i = 0; i < _tracks.length; i++) {
            TrackEntry current = _tracks[i];
            if(current is null)
                continue;
            float trackDelta = delta * current.timeScale;
            float time = current.time + trackDelta;
            float endTime = current.endTime;

            current.time = time;
            if(current.previous !is null) {
                current.previous.time = current.previous.time + trackDelta;
                current.mixTime += trackDelta;
            }

            // Check if completed the animation or a loop iteration.
            if(current.loop ? (current.lastTime % endTime > time % endTime) : (current.lastTime < endTime && time >= endTime)) {
                int count = cast(int)(time / endTime);
                current.complete.emit(this, i, count);
                complete.emit(this, i, count);
            }

            TrackEntry next = current.next;
            if(next !is null) {
                next.time = current.lastTime - next.delay;
                if(next.time >= 0)
                    setCurrent(i, next);
            } else {
                // End non-looping animation when it reaches its end time and there is no next entry.
                if (!current.loop && current.lastTime >= current.endTime)
                    clearTrack(i);
            }
        }
    }

    void apply(Skeleton skeleton) {
        for(int i = 0; i < _tracks.length; i++) {
            TrackEntry current = _tracks[i];
            if(current is null)
                continue;

            _events.length = 0;
            auto eventsAppender = appender!(Event[])(_events);
            float time = current.time;
            bool loop = current.loop;
            if(!loop && time > current.endTime)
                time = current.endTime;
            TrackEntry previous = current.previous;
            if(previous is null) {
                if(current.mix == 1)
                    current.animation.apply(skeleton, current.lastTime, time, loop, eventsAppender);
                else
                    current.animation.mix(skeleton, current.lastTime, time, loop, eventsAppender, current.mix);
            } else {
                float previousTime = previous.time;
                if(!previous.loop && previousTime > previous.endTime)
                    previousTime = previous.endTime;
                //previous.animation.apply(skeleton, previous.lastTime, previousTime, previous.loop, null);
				// Remove the line above, and uncomment the line below, to allow previous animations to fire events during mixing.
				previous.animation.apply(skeleton, previous.lastTime, previousTime, previous.loop, eventsAppender);
				previous.lastTime = previousTime;

                float alpha = current.mixTime / current.mixDuration * current.mix;
                if(alpha >= 1) {
                    alpha = 1;
                    current.previous = null;
                }
                current.animation.mix(skeleton, current.lastTime, time, loop, eventsAppender, alpha);
            }

            for(int ii = 0; ii < _events.length; ii++) {
                Event e = _events[ii];
                current.event.emit(this, i, e);
                event.emit(this, i, e);
            }

            current.lastTime = current.time;
        }
    }

    void clearTracks() {
        for(int i = 0; i < _tracks.length; i++)
            clearTrack(i);
        _tracks.length = 0;
    }

    void clearTrack(int trackIndex) {
        if(trackIndex >= _tracks.length)
            return;
        TrackEntry current = _tracks[trackIndex];
        if(current is null)
            return;

        current.end.emit(this, trackIndex);
        end.emit(this, trackIndex);
        _tracks[trackIndex] = null;
    }

    private TrackEntry expandToIndex(int index) {
        if(index < _tracks.length)
            return _tracks[index];
        //alternative: _tracks.length = index
        while (index >= _tracks.length)
            _tracks ~= null;
        return null;
    }

    private void setCurrent(int index, TrackEntry entry) {
        TrackEntry current = expandToIndex(index);
        if(current !is null) {
            TrackEntry previous = current.previous;
            current.previous = null;

            current.end.emit(this, index);
            end.emit(this, index);
            entry.mixDuration = data.getMix(current.animation, entry.animation);
            if(entry.mixDuration > 0) {
                entry.mixTime = 0;
                // If a mix is in progress, mix from the closest animation.
                if(previous !is null && current.mixTime / current.mixDuration < 0.5f)
                    entry.previous = previous;
                else
                    entry.previous = current;
            }
        }

        _tracks[index] = entry;

        entry.start.emit(this, index);
        start.emit(this, index);
    }

    TrackEntry setAnimation(int trackIndex, string animationName, bool loop) {
        Animation animation = data.skeletonData.findAnimation(animationName);
        if(animation is null)
            throw new Exception("Animation not found: " ~ animationName);
        return setAnimation(trackIndex, animation, loop);
    }

    TrackEntry setAnimation(int trackIndex, Animation animation, bool loop) {
        mixin(ArgNull!animation);
        TrackEntry entry = new TrackEntry();
        entry.animation = animation;
        entry.loop = loop;
        entry.time = 0;
        entry.endTime = animation.duration;
        setCurrent(trackIndex, entry);
        return entry;
    }

    TrackEntry addAnimation(int trackIndex, string animationName, bool loop, float delay = 0) {
        Animation animation = data.skeletonData.findAnimation(animationName);
        if(animation is null)
            throw new Exception("Animation not found: "~animationName);
        return addAnimation(trackIndex, animation, loop, delay);
    }

    TrackEntry addAnimation(int trackIndex, Animation animation, bool loop, float delay = 0) {
        mixin(ArgNull!animation);
        TrackEntry entry = new TrackEntry();
        entry.animation = animation;
        entry.loop = loop;
        entry.time = 0;
        entry.endTime = animation.duration;

        TrackEntry last = expandToIndex(trackIndex);
        if(last !is null) {
            while(last.next !is null)
                last = last.next;
            last.next = entry;
        } else {
            _tracks[trackIndex] = entry;
        }

        if(delay <= 0) {
            if(last !is null)
                delay += last.endTime - data.getMix(last.animation, animation);
            else
                delay = 0;
        }
        entry.delay = delay;
        return entry;
    }

    TrackEntry getCurrent(int trackIndex) {
        if(trackIndex >= _tracks.length)
            return null;
        return _tracks[trackIndex];
    }

    override string toString() {
        auto buffer = appender!string();
        for(int i = 0; i < _tracks.length; i++)
        {
            TrackEntry entry = _tracks[i];
            if(entry is null)
                continue;
            if(buffer.data.length > 0)
                buffer ~= ", ";
            buffer ~= entry.toString();
        }
        if(buffer.data.length == 0)
            return "<none>";
        return buffer.data;
    }

private:
    AnimationStateData _data;
    TrackEntry[] _tracks;
    Event[] _events;
    float _timeScale;
}
