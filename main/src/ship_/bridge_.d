module ship_.bridge_;

import accessors;
import std.algorithm;

import watch_var_;
import ship_.ports_;
import ship_.terminal_;

class Bridge : Port {
	@Read
	WatchArray!Port	ports_	;
	
	this() {
		super(PortType.bridge);
		ports_ = [this];
	}
	
	void addPort(Port port) {
		assert(ports_.values.length <= ushort.max);
		port.id = cast(ushort) ports_.values.length;
		ports_.addValue(port);
	}
	void removePort(size_t index) {
		assert(index > 0);
		ports_.removeValue(index);
	}
	
	auto portsOf(PortType type)() {
		return ports.map(p=>p.safeCast!type).filter(p=>p!=null);
	}
	
	override
	void recvMsg(Terminal terminal, ubyte[] msg) {
		assert(false);
	}
	
	mixin(GenerateFieldAccessors);
} 


