module ship_.net_ports_.bridge_;

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import treeserial;
import structuredrpc;

import ship_.bridge_;

import ship_.net_ports_.port_;
import ship_.net_ports_.bridge_;
import ship_.net_ports_.wire_;

abstract
class NetBridge : NetPort {
	this() {
		this_!(typeof(this));
	}
	@ConstRead {
		NetPort[] _ports;
	}
	alias Branch = NetBridgeBranch;
	alias Root = NetBridgeRoot;
}

class NetBridgeBranch : NetBridge {
	Client[] clients = [];
	
	this() {
		this._ports = [this];
	}
	
	void newClients(Client[] newClients) {
		clients ~= newClients;
		addPorts_send!TrgtClients(newClients, _ports[1..$].map!(p=>p.type).array);
	}
	
	@RPC!SrcServer(0)
	void __addPorts(PortType[] types) {
		NetPort addPort(PortType type) {
			NetPort addPort(alias type)() {
				alias P = getUDAs!(type, PortClass)[0].PortClass.Branch;
				return new P();
			}
			final switch(type) {
				case PortType.bridge:
					assert(false);
				case PortType.wire:
					return addPort!(PortType.wire);
				////case PortType.wireIn:
				////	return addPort!(PortType.wireIn);
				////case PortType.wireOut:
				////	return addPort!(PortType.wireOut);
				////case PortType.pingOut:
				////	return addPort!(PortType.pingOut);
				////case PortType.radar:
				////	return addPort!(PortType.radar);
				////case PortType.spawner:
				////	return addPort!(PortType.spawner);
			}
		}
		__plugInPorts(types.map!((PortType t)=>addPort(t)).array);
	}
	
	void __plugInPorts(NetPort[] newPorts...) {
		assert(_ports.length + newPorts.length <= typeof(NetPort.id).max);
		foreach (i, port; newPorts) {
			port.id = cast(typeof(NetPort.id)) (_ports.length+i);
		}
		_ports ~= newPorts;
		addPorts_send!TrgtClients(clients, newPorts.map!(p=>p.type).array);
	}
	
	mixin NetPortMixin!(false, NetBridgeRoot);
}

class NetBridgeRoot : NetBridge {
	Bridge bridge;
	
	Client[] clients = [];
	
	this (Bridge bridge) {
		this._ports = [this];
		this.bridge = bridge;
	}
	
	void update() {
		foreach (client; clients) {
			foreach (msg; client) {
				dispatchClientMsg(client, msg);
			}
		}
	}
	void dispatchClientMsg(Client client, const(ubyte)[] msgData) {
		// TODO: Possible crash
		auto portID = msgData.deserialize!ubyte;
		_ports[portID].recvClientMsg(client, msgData);
	}
	
	void newClients(Client[] newClients) {
		clients ~= newClients;
		addPorts_send!TrgtClients(newClients, _ports[1..$].map!(p=>p.type).array);
	}
	
	size_t plugInPort(NetPort n) {
		plugInPorts(n);
		return _ports.length-1;
	}
	void plugInPorts(NetPort[] newPorts...) {
		assert(_ports.length + newPorts.length <= typeof(NetPort.id).max);
		foreach (i, port; newPorts) {
			port.id = cast(typeof(NetPort.id)) (_ports.length+i);
		}
		_ports ~= newPorts;
		addPorts_send!TrgtClients(clients, newPorts.map!(p=>p.type).array);
	}
	
	mixin NetPortMixin!(true, NetBridgeBranch);
}




