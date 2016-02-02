module spine.animation.state.data;

import spine.animation.animation;
import spine.skeleton.data;
import spine.util.argnull;

export class AnimationStateData {

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

    private @property {
        float[Key] animationToMixTime() {
            return _animationToMixTime;
        }
        void animationToMixTime(float[Key] value) {
            _animationToMixTime = value;
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
        animationToMixTime[Key(from, to)] = duration;
    }

    float getMix(Animation from, Animation to) {
        return animationToMixTime.get(Key(from, to), defaultMix);
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