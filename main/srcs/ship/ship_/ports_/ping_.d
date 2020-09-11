
struct PingMaster {
	// This line must be here (for every port) (at the vary beginning).  It is a form of inheritance magic.  Changing this will invoke dragons...
	PingSlave*[] slaves;
	
	byte _pings;
	float _newPings;
	
	@property byte pings() {
		return _pings;
	}
	void ping() {
		// TODO: validate.
		_pings++;
		slaves.each!(s=>s._pings++);
	}
	
	void update() {
		_pings = _nextPings;
		slaves.each!(s=>s._pings = _nextPings);
		_nextPings = 0;
	}
}

struct PingSlave {
	// This line must be here (for every port) (at the vary beginning).  It is a form of inheritance magic.  Changing this will invoke dragons...
	PingMaster* master;
	
	byte _pings;
	
	@property byte pings() {
		return _pings;
	}
	void ping() {
		// TODO: validate.
		_pings++;
		if (master)
			master._newPings++;
	}
}
