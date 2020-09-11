
struct WireMaster {
	// This line must be here (for every port) (at the vary beginning).  It is a form of inheritance magic.  Changing this will invoke dragons...
	WireSlave*[] slaves;
	
	float _value;
	
	@property float value() {
		return _value;
	}
	void setValue(float n) {
		// TODO: validate.
		_value = n;
		slaves.each!(s=>s._value = n);
	}
	
	void update() {
		setValue(_value);
	}
}

struct WireSlave {
	// This line must be here (for every port) (at the vary beginning).  It is a form of inheritance magic.  Changing this will invoke dragons...
	WireMaster* master;
	
	float _value;
	
	@property float value() {
		return _value;
	}
	void setValue(float n) {
		// TODO: validate.
		_value = n;
		if (master)
			master._value = n;
	}
}
