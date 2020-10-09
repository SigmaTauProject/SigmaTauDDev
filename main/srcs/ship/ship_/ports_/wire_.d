module ship_.ports_.wire_;


struct WireMaster {
	//---POD
	float _value = 0;
	float _nextValue = 0;
	
	NetWireConnection net;
	
	//---methods
	@property float value() {
		return _value;
	}
	void setValue(float n) {
		// TODO: validate.
		if (n != _value) {
			_value = n;
			_nextValue = n;
			if (net)
				net.onSetValue;
		}
	}
	
	void update() {
		setValue(_nextValue);
	}
	
	@property
	WireSlave* slave() {
		return cast(WireSlave*) &this;
	}
}

struct WireSlave {
	//---POD
	float _value;
	float _nextValue;
	
	//---methods
	@property float value() {
		return _value;
	}
	void setValue(float n) {
		// TODO: validate.
		_nextValue = n;
	}
}

abstract class NetWireConnection {
	WireSlave* port;
	
	this(WireSlave* port) {
		this.port = port;
		(cast(WireMaster*) port).net = this;
	}
	
	void setValue(float n) {
		port._value = n;
		port._nextValue = n;
	}
	
	abstract void onSetValue();
}
