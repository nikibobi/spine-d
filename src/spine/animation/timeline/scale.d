module spine.animation.timeline.scale;

import spine.animation.animation;
import spine.animation.timeline.translate;
import spine.bone.bone;
import spine.event.event;
import spine.skeleton.skeleton;

export class ScaleTimeline : TranslateTimeline {

    this(int frameCount) {
        super(frameCount);
    }

    override void apply(Skeleton skeleton, float lastTime, float time, Event[] events, float alpha) {
        if(time < frames[0])
            return;

        Bone bone = skeleton.bones[boneIndex];
        if(time >= frames[$ - 3]) {
            bone.scaleX = bone.scaleX + (bone.data.scaleX * frames[$ - 2] - bone.scaleX) * alpha;
            bone.scaleY = bone.scaleY + (bone.data.scaleY * frames[$ - 1] - bone.scaleY) * alpha;
            return;
        }

        int frameIndex = Animation.binarySearch(frames, time, 3);
        float lastFrameX = frames[frameIndex - 2];
        float lastFrameY = frames[frameIndex - 1];
        float frameTime = frames[frameIndex];
        float percent = 1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime);
        percent = getCurvePercent(frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

        bone.scaleX = bone.scaleX + (bone.data.scaleX * (lastFrameX + (frames[frameIndex + FRAME_X] - lastFrameX) * percent) - bone.scaleX) * alpha;
        bone.scaleY = bone.scaleY + (bone.data.scaleY * (lastFrameY + (frames[frameIndex + FRAME_Y] - lastFrameY) * percent) - bone.scaleY) * alpha;
    }
}