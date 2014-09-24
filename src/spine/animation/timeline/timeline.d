module spine.animation.timeline.timeline;

import spine.skeleton.skeleton;

export interface Timeline {
    //TODO: change signeture to use events and last time
    void apply(Skeleton skeleton, float time, float alpha);
}