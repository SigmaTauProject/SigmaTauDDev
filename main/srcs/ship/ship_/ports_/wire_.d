module ship_.ports_.wire_;


struct WirePort {
	WirePort**[] connections;
	
	//---POD
	float _value = 0;
	
	//---methods
	@property float value() {
		return _value;
	}
	void setValue(float n) {
		// TODO: validate.
		_value = n;
	}
}
