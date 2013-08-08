module spine.animation.timeline.timeline;

export interface Timeline {
    void apply(Skeleton skeleton, float time, float alpha);
}