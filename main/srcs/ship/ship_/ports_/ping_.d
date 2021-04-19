module ship_.ports_.ping_;


struct PingPort {
	PingPort**[] connections;
	
	//---POD
	ubyte _pings = 0;
	ubyte _nextPings = 0;
	
	//---methods
	@property ubyte pings() {
		return _pings;
	}
	void ping() {
		_nextPings++;
	}
	
	//---special
	void update() {
		_pings = _nextPings;
		_nextPings = 0;
	}
}