
struct WireMaster {
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(WireSlave);
	
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
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(WireMaster);
	
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
