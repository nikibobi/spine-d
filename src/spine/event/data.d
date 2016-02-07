module spine.event.data;

import spine.util.argnull;

export class EventData {

	this(string name) {
		mixin(ArgNull!name);
		_name = name;
	}

	@property {
	    string name() {
	        return _name;
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
		return name;
	}

private:
	string _name;
	int _integer;
	float _number;
	string _text;
}