module spine.animation.timeline.ffd;

import spine.animation.animation;
import spine.animation.timeline.curve;
import spine.attachment.attachment;
import spine.event.event;
import spine.skeleton.skeleton;
import spine.slot.slot;

export class FFDTimeline : CurveTimeline {

    this(int frameCount) {
        super(frameCount);
        frames = new float[frameCount];
        vertices = new float[][frameCount];
    }

    @property {
        int slotIndex() {
            return _slotIndex;
        }
        void slotIndex(int value) {
            _slotIndex = value;
        }
    }

    @property {
        ref float[] frames() {
            return _frames;
        }
        void frames(float[] value) {
            _frames = value;
        }
    }

    @property {
        ref float[][] vertices() {
            return _frameVertices;
        }
        void vertices(float[][] value) {
            _frameVertices = value;
        }
    }

    @property {
        Attachment attachment() {
            return _attachment;
        }
        void attachment(Attachment value) {
            _attachment = value;
        }
    }

    void setFrame(int frameIndex, float time, float[] vertices) {
        this.frames[frameIndex] = time;
        this.vertices[frameIndex] = vertices;
    }

    override void apply(E)(Skeleton skeleton, float lastTime, float time, E firedEvents, float alpha) {
        Slot slot = skeleton.slots[slotIndex];
        if(slot.attachment != attachment)
            return;
        if(time < frames[0]) // Time is before first frame.
            return;

        float[][] frameVertices = this.vertices;
        int vertexCount = frameVertices[0].length;

        float[] vertices = slot.attachmentVertices;
        if(vertices.length < vertexCount) {
            vertices = new float[vertexCount];
			vertices[] = 0f;
            slot.attachmentVertices = vertices;
        }
        if(vertices.length != vertexCount)
            alpha = 1; // Don't mix from uninitialized slot vertices.
        slot.attachmentVerticesCount = vertexCount;

        if(time >= frames[$ - 1]) { // Time is after last frame.
            float[] lastVertices = frameVertices[$ - 1];
            if(alpha < 1) {
                for(int i = 0; i < vertexCount; i++) {
                    float vertex = vertices[i];
                    vertices[i] = vertex + (lastVertices[i] - vertex) * alpha;
                }
            } else {
                vertices[] = lastVertices[0..vertexCount];
            }
            return;
        }

        int frameIndex = Animation.binarySearch(frames, time);
        float frameTime = frames[frameIndex];
        float percent = 1 - (time - frameTime) / (frames[frameIndex - 1] - frameTime);
        percent = getCurvePercent(frameIndex - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));
        
        float[] prevVertices = frameVertices[frameIndex - 1];
        float[] nextVertices = frameVertices[frameIndex];

        if(alpha < 1) {
            for(int i = 0; i < vertexCount; i++) {
                float prev = prevVertices[i];
                float vertex = vertices[i];
                vertices[i] = vertex + (prev + (nextVertices[i] - prev) * percent - vertex) * alpha;               
            }
        } else {
            for(int i = 0; i < vertexCount; i++) {
                float prev = prevVertices[i];
                vertices[i] = prev + (nextVertices[i] - prev) * percent;
            }
        }
    }

private:
    int _slotIndex;
    float[] _frames;
    float[][] _frameVertices;
    Attachment _attachment;
}