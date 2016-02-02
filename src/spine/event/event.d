module spine.event.event;

import spine.event.data;

export class Event {

	this(EventData data) {
		this.data = data;
	}

	@property {
	    EventData data() {
	        return _data;
	    }
	    private void data(EventData value) {
	        _data = value;
	    }
	}

	@property {
	    int integer() {
	        return _integer;
	    }
	    void integer(int value) {
	        _integer = value;
	    }
	}

	@property {
	    float number() {
	        return _number;
	    }
	    void number(float value) {
	        _number = value;
	    }
	}

	@property {
	    string text() {
	        return _text;
	    }
	    void text(string value) {
	        _text = value;
	    }
	}

	override string toString() {
		return data.name;
	}

private:
	EventData _data;
	int _integer;
	float _number;
	string _text;
}