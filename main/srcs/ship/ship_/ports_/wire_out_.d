
struct WireOutMaster {
	// This line must be here (for every port) (at the vary beginning).  It is a form of inheritance magic.  Changing this will invoke dragons...
	WireOutSlave*[] slaves;
	
	float _value;
	
	@property float value() {
		return _value;
	}
	void setValue(float n) {
		// TODO: validate.
		_value = n;
		slaves.each!(s=>s._value = n);
	}
}

struct WireOutSlave {
	// This line must be here (for every port) (at the vary beginning).  It is a form of inheritance magic.  Changing this will invoke dragons...
	WireOutMaster* master;
	
	float _value;
	
	@property float value() {
		return _value;
	}
}
