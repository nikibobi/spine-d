module spine.animation.timeline.timeline;

import std.range.primitives;

import spine.event.event;
import spine.skeleton.skeleton;

export interface Timeline {
    void apply(E)(Skeleton skeleton, float lastTime, float time, E events, float alpha)
    if(isOutputRange!(E, Event));
}
