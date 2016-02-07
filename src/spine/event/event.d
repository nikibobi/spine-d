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

	@property T get(T)() {
		static if(is(T == int))
		{
			return _integer;
		}
		static if(is(T == float))
		{
			return _number;
		}
		static if(is(T == string))
		{
			return _text;
		}
	}

	@property void set(T)(T value) {
		static if(is(T == int))
		{
			_integer = value;
		}
		static if(is(T == float))
		{
			_number = value;
		}
		static if(is(T == string))
		{
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