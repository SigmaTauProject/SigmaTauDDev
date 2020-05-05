module ship_.ports_;

import watch_var_;
public import ship_.bridge_;
import ship_.terminal_;

enum PortType : ubyte {
	bridge	,
	wireOut	,
	wireIn	,
	radar	,
}

abstract
class Port {
	PortType type;
	ushort id;
	this(PortType type) {
		this.type = type;
	}
	auto safeCast(PortType toType)() {
		if (toType==type)
			return cast(PortTypeType!toType) this;
		else
			return null;
	}
	
	abstract
	void recvMsg(Terminal terminal, ubyte[] msg);
}
class WireOutPort : Port {
	WatchVar!float value;
	this (float value) {
		super(PortType.wireOut);
		this.value = WatchVar!float(value);
	}
	override
	void recvMsg(Terminal terminal, ubyte[] msg) {
		assert(false, "Unimplemented");
	}
}
class RadarPort : Port {
	this () {
		super(PortType.radar);
	}
	override
	void recvMsg(Terminal terminal, ubyte[] msg) {
		assert(false);
	}
}

template PortTypeType(PortType type) {
	static if (type==PortType.bridge) {
		alias PortTypeType = Bridge;
	}
	else static if (type==PortType.wireOut) {
		alias PortTypeType = WireOutPort;
	}
	else static if (type==PortType.wireIn) {
		////alias PortTypeType = WireInPort;
	}
	else static if (type==PortType.radar) {
		alias PortTypeType = RadarPort;
	}
	else static assert(false);
}

