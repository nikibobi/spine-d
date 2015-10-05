module spine.animation.timeline.flipy;

import spine.animation.timeline.flip;
import spine.bone.bone;

export class FlipYTimeline : FlipTimeline {
    
    override protected void setFlip(Bone bone, bool flip) {
        bone.flipY = flip;
    }
}