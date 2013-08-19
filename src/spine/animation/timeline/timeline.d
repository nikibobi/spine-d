module spine.animation.timeline.timeline;

import spine.skeleton.skeleton;

export interface Timeline {
    void apply(Skeleton skeleton, float time, float alpha);
}