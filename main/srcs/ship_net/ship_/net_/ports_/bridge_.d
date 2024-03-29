module ship_.net_.ports_.bridge_;

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import std.string;
import std.conv;
import std.typecons;
import treeserial;
import structuredrpc;

import ship_.components_.bridge_;
import ship_.net_.port_;

static foreach (portName; portNames) {
	mixin("import ship_.net_.ports_."~portName~"_;");
}

class NetBridgeBranch : NetPort {
	NetPort[] ports;
	Client[] clients = [];
	
	this() {
		super(portType!(typeof(this)), 0, 0);
		this.ports = [this];
	}
	
	void newClients(Client[] newClients) {
		clients ~= newClients;
		updatePorts_send!TrgtClients(newClients, [], ports[1..$].map!(p=>tuple(p.type,p.typeID)).array);
	}
	
	@RPC!SrcServer(0)
	void __updatePorts(ubyte[] removedPorts, Tuple!(const PortType, const ubyte)[] addedPorts) {
		assert(false, "Unimplemented");
		////NetPort addPort(PortType type) {
		////	NetPort addPort(alias type)() {
		////		static if (type == PortType.bridge)
		////			assert(false);
		////		alias P = getUDAs!(type, PortClass)[0].PortClass.Branch;
		////		return new P();
		////	}
		////	toCTEnum!addPort(type);
		////}
		////__plugInPorts(types.map!((PortType t)=>addPort(t)).array);
	}
	@RPC!SrcServer(1)
	void __update() {
		assert(false, "Unimplemented");
	}
	
	////void __plugInPorts(NetPort[] newPorts...) {
	////	assert(ports.length + newPorts.length <= typeof(NetPort.id).max);
	////	foreach (i, port; newPorts) {
	////		port.id = cast(typeof(NetPort.id)) (ports.length+i);
	////	}
	////	ports ~= newPorts;
	////	addPorts_send!TrgtClients(clients, newPorts.map!(p=>p.type).array);
	////}
	
	mixin NetPortMixin!(false, NetBridge);
}

class NetBridge : NetPort {
	Bridge bridge;
	Client[] clients = [];
	HoldArray!NetPort ports;
	static foreach (portName; portNames) {
		mixin("Net"~portName.capitalize~"[] "~portName~"s;");
	}
	
	this (Bridge bridge) {
		super(portType!(typeof(this)), 0, 0);
		this.bridge = bridge;
		this.ports = HoldArray!NetPort([this]);
	}
	
	void updateSend() {
		// TODO: Never remove to reorder.
		ubyte[] removedPorts;
		Tuple!(const PortType, const ubyte)[] addedPorts;
		{
			size_t currentID = 1;// Skip bridge which is 0.
			static foreach (portName; portNames) {
				(ref typeof(mixin("bridge."~portName~"s")) ports, ref mixin("Net"~portName.capitalize)[] netPorts) {
					netPorts.length = max(ports.length, netPorts.length);
					foreach (i, ref netPort; netPorts) {
						if (netPort !is null && (i >= ports.length || ports[i] != netPort.portPointer)) {
							//---Remove Port
							removedPorts ~= i.to!ubyte;
							netPort = null;
							this.ports.remove(netPort.id);
						}
						if (i < ports.length && ports[i] !is null && (netPort is null || ports[i] != netPort.portPointer)) {
							//---Add Port
							ubyte id = this.ports.add(null).to!ubyte;
							netPort = new typeof(netPort)(ports[i], id, i.to!ubyte);
							this.ports[id] = netPort;
							addedPorts ~= tuple(netPort.type, cast(const) i.to!ubyte);
						}
					}
					netPorts.length = min(ports.length, netPorts.length);
				}(mixin("bridge."~portName~"s"), mixin(portName~"s"));
				////foreach (i, port; mixin("bridge."~portName~"s")) {
				////	if (mixin("last"~port.capitalize~"s;")[i] != port) {
				////		removed 
				////	}
				////	auto f = ports[currentID..$].countUntil!(p=>p.portPointer == port);
				////	if (f == -1) {
				////		//---Add Port
				////		ubyte id = ports.add(null).to!ubyte;
				////		auto p = mixin("new Net"~portName.capitalize~"(port, id)");
				////		ports[id] = p;
				////		addedPorts ~= p.type;
				////	}
				////	else {
				////		//---Remove Ports (if needed)
				////		////foreach (i; currentID..currentID+f) {
				////		////	removedPorts ~= cast(ubyte) i;
				////		////	ports.remove(i);
				////		////}
				////		currentID += f;
				////	}
				////	currentID ++;
				////}
			}
		}
		if (removedPorts.length || addedPorts.length)
			updatePorts_send!TrgtClients(clients, removedPorts, addedPorts);
		foreach (port; ports[1..$])
			port.update;
		update_send!TrgtClients(clients);
	}
	override
	void update() {
		foreach (client; clients) {
			const(ubyte)[] msg;
			while (client.pullMsg(&msg)) {
				dispatchClientMsg(client, msg);
			}
		}
		foreach (port; ports[1..$]) {
			port.postUpdate;
		}
	}
	void dispatchClientMsg(Client client, const(ubyte)[] msgData) {
		// TODO: Possible crash
		auto portID = msgData.deserialize!ubyte;
		ports[portID].recvClientMsg(client, msgData);
	}
	
	void newClients(Client[] newClients) {
		clients ~= newClients;
		updatePorts_send!TrgtClients(newClients, [], ports[1..$].map!(p=>tuple(p.type,p.typeID)).array);
	}
	
	////size_t plugInPort(NetPort n) {
	////	plugInPorts(n);
	////	return ports.length-1;
	////}
	////void plugInPorts(NetPort[] newPorts...) {
	////	assert(ports.length + newPorts.length <= typeof(NetPort.id).max);
	////	foreach (i, port; newPorts) {
	////		port.id = cast(typeof(NetPort.id)) (ports.length+i);
	////	}
	////	ports ~= newPorts;
	////	updatePorts_send!TrgtClients(clients, [], newPorts.map!(p=>p.type).array);
	////}
	
	mixin NetPortMixin!(true, NetBridgeBranch);
}

auto toCTEnum(alias f, E)(E e) {
	final switch(e) {
		static foreach(t; EnumMembers!E) {
			case t:
				return fun!t;
		}
	}
}

struct HoldArray(T) {
	T[] array;
	alias array this;
	size_t nextHole = -1;
	
	this(T[] array) {
		this.array = array;
		nextHole = _findNextHole;
	}
	
	size_t add(T a) {
		if (nextHole == -1) {
			array ~= a;
			return array.length-1;
		}
		else {
			assert(array[nextHole] is null);
			array[nextHole] = a;
			scope(success)
				nextHole = _findNextHole;
			return nextHole;
		}
	}
	void remove(size_t i) {
		array[i] = null;
		if (i == array.length) {
			array.length--;
			array.assumeSafeAppend;
		}
		else if (i < nextHole)
			nextHole = i;
	}
	size_t _findNextHole() {
		size_t hole = nextHole;
		do {
			hole ++;
			if (hole >= array.length)
				return -1;
		} while(array[hole] !is null);
		return hole;
	}
}

