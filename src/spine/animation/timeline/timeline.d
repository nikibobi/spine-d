module spine.animation.timeline.timeline;

import spine.event.event;
import spine.skeleton.skeleton;

export interface Timeline {
    void apply(Skeleton skeleton, float lastTime, float time, Event[] events, float alpha);
}