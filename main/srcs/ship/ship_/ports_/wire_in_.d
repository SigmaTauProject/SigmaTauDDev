
struct WireInMaster {
	// This line must be here (for every port) (at the vary beginning).  It is a form of inheritance magic.  Changing this will invoke dragons...
	WireInSlave*[] slaves;
	
	float _value;
	
	@property float value() {
		return _value;
	}
}

struct WireInSlave {
	// This line must be here (for every port) (at the vary beginning).  It is a form of inheritance magic.  Changing this will invoke dragons...
	WireInMaster* master;
	
	void setValue(float n) {
		// TODO: validate.
		if (master)
			master._value = n;
	}
}
