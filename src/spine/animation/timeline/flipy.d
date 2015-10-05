module spine.animation.timeline.flipy;

import spine.animation.timeline.flip;
import spine.bone.bone;

export class FlipYTimeline : FlipTimeline {

    this(int frameCount) {
        super(frameCount);
    }
    
    override protected void setFlip(Bone bone, bool flip) {
        bone.flipY = flip;
    }
}