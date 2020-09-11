
struct WireOutMaster {
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(WireOutSlave);
	
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
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(WireOutMaster);
	
	float _value;
	
	@property float value() {
		return _value;
	}
}
