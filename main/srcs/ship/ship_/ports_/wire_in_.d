
struct WireInMaster {
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(WireInSlave);
	
	float _value;
	
	@property float value() {
		return _value;
	}
}

struct WireInSlave {
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(WireInMaster);
	
	void setValue(float n) {
		// TODO: validate.
		if (master)
			master._value = n;
	}
}
