module ship_.ports_.wire_;


struct WirePort {
	WirePort**[] connections;
	
	//---POD
	float _value = 0;
	bool _twitched = false;
	
	//---methods
	@property float value() {
		return _value;
	}
	void setValue(float n) {
		// TODO: validate.
		_value = n;
	}
	@property bool twitched() {
		return _twitched;
	}
	void twitch() {
		_twitched = true;
	}
	
	//---special
	void update() {
		_twitched = false;
	}
}
