module spine.event.data;

import spine.util.argnull;

export class EventData {

	this(string name) {
		mixin(ArgNull!name);
		this.name = name;
	}

	@property {
	    string name() {
	        return _name;
	    }
	    private void name(string value) {
	        _name = value;
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
		return name;
	}

private:
	string _name;
	int _integer;
	float _number;
	string _text;
}