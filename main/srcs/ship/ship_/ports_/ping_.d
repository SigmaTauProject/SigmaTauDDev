
struct PingMaster {
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(PingSlave);
	
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
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(PingMaster);
	
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
