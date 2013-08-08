module spine.animation.state.state;

export class AnimationState {

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