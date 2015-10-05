module spine.animation.timeline.flipx;

import spine.animation.timeline.flip;
import spine.bone.bone;

export class FlipXTimeline : FlipTimeline {

    this(int frameCount) {
        super(frameCount);
    }
    
    override protected void setFlip(Bone bone, bool flip) {
        bone.flipX = flip;
    }
}