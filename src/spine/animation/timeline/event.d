module spine.animation.timeline.event;

import spine.animation.animation;
import spine.animation.timeline.timeline;
import spine.event.event;
import spine.skeleton.skeleton;

export class EventTimeline : Timeline {

	this(int frameCount) {
		frames.length = frameCount;
		events.length = frameCount;
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
	    ref Event[] events() {
	        return _events;
	    }
	    void events(Event[] value) {
	        _events = value;
	    }
	}

	@property {
	    int frameCount() {
	        return frames.length;
	    }
	}

	void setFrame(int frameIndex, float	time, Event e) {
		frames[frameIndex] = time;
		events[frameIndex] = e;
	}

	void apply(E)(Skeleton skeleton, float lastTime, float time, E firedEvents, float alpha) {
		// if(firedEvents is null)
		// 	return;
		if(lastTime > time) {
			apply(skeleton, lastTime, lastTime, firedEvents, alpha);
			lastTime = -1f;
		} else if(lastTime >= frames[$ - 1]) {
			return;
		}
		if(time < frames[0])
			return;
		int frameIndex;
		if(lastTime < frames[0]) {
			frameIndex = 0;
		} else {
			frameIndex = Animation.binarySearch(frames, lastTime);
			float frame = frames[frameIndex];
			while (frameIndex > 0) {
				if(frames[frameIndex - 1] != frame)
					break;
				frameIndex--;
			}
		}
		for(; frameIndex < frameCount && time >= frames[frameIndex]; frameIndex++)
			firedEvents.put(events[frameIndex]);
	}

private:
	float[] _frames;
	Event[] _events;
}