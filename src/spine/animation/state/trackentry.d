module spine.animation.state.trackentry;

import std.signals;

import spine.animation.animation;
import spine.animation.state.state;
import spine.event.event;

class TrackEntry {

    this() {
        lastTime = -1;
        timeScale = 1;
        mix = 1;
    }

    mixin Signal!(AnimationState, int) start;
    mixin Signal!(AnimationState, int) end;
    mixin Signal!(AnimationState, int, Event) event;
    mixin Signal!(AnimationState, int, int) complete;

    @property {
        Animation animation() {
            return _animation;
        }
        package void animation(Animation value) {
            _animation = value;
        }
    }

    @property {
        float delay() {
            return _delay;
        }
        void delay(float value) {
            _delay = value;
        }
    }

    @property {
        float time() {
            return _time;
        }
        void time(float value) {
            _time = value;
        }
    }

    @property {
        float lastTime() {
            return _lastTime;
        }
        void lastTime(float value) {
            _lastTime = value;
        }
    }

    @property {
        float endTime() {
            return _endTime;
        }
        void endTime(float value) {
            _endTime = value;
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

    @property {
        float mix() {
            return _mix;
        }
        void mix(float value) {
            _mix = value;
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

    override string toString() {
        return animation is null ? "<none>" : animation.toString();
    }

package:
    TrackEntry next, previous;
    Animation _animation;
    bool _loop;
    float _delay, _time, _lastTime, _endTime, _timeScale;
    float mixTime, mixDuration, _mix;
}