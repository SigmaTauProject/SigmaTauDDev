module ship_.ports_.ping_;


struct PingMaster {
	//---POD
	ubyte _pings = 0;
	ubyte _nextPings = 0;
	
	NetPingConnection net;
	
	//---methods
	@property ubyte pings() {
		return _pings;
	}
	void ping() {
		_pings++;
		if (net) net.onPing;
	}
	
	void update() {
		_pings = 0;
		foreach(_; 0.._nextPings)
			ping();
		_nextPings = 0;
	}
	
	@property
	PingSlave* slave() {
		return cast(PingSlave*) &this;
	}
}

struct PingSlave {
	//---POD
	ubyte _pings;
	ubyte _nextPings;
	
	NetPingConnection net;
	
	//---methods
	@property ubyte pings() {
		return _pings;
	}
	void ping() {
		_nextPings++;
	}
}

abstract class NetPingConnection {
	PingSlave* port;
	
	this(PingSlave* port) {
		this.port = port;
		port.net = this;
	}
	
	void ping() {
		port._pings++;
	}
	
	abstract void onPing();
}
