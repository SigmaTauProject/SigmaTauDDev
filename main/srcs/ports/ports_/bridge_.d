module ports_.bridge_;

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import treeserial;
import structuredrpc;

import ports_.port_;
import ports_.bridge_;
import ports_.wire_;

class Bridge(bool isMaster) : Port!isMaster {
	private:
	
	//---Fields
	@ConstRead
	Port!isMaster[]	_ports	;
	mixin(GenerateFieldAccessors);
	
	//---Constructors
	public
	this() {
		this_!(typeof(this));
		_ports = [this];
	}
	
	//---Private Members
	Client[] clients;
	
	//---Bridge Code
	public
	void newClients(Client[] clients) {
		if (clients.length)
			addPorts_send!(Trgt.clients)(clients, _ports[1..$].map!(p=>p.type).array);
	}
	public
	void dispatchClientMsg(Client client, const(ubyte)[] msgData) {
		// TODO: Possible crash
		auto portID = msgData.deserialize!ubyte;
		_ports[portID].recvClientMsg(client, msgData);
	}
	
	//---Messages
	@RPC(0)
	void addPorts(Src src:Src.server)(PortType[] types) {
		assert(!isMaster);
		static if (!isMaster)
			types.each!((PortType t)=>addPort!src(t));
	}
	
	private
	void addPort(Src src:Src.server)(PortType type) {
		assert(!isMaster);
		static if (!isMaster) {
			auto addPort(alias type)() {
				alias P = getUDAs!(type, PortClass)[0].PortClass;
				plugInPort(new P!isMaster());
			}
			Port!isMaster port;
			final switch(type) {
				case PortType.bridge:
					assert(false);
				case PortType.wire:
					port = addPort!(PortType.wire);
					break;
				case PortType.wireIn:
					port = addPort!(PortType.wireIn);
					break;
				case PortType.wireOut:
					port = addPort!(PortType.wireOut);
					break;
				case PortType.radar:
					port = addPort!(PortType.radar);
					break;
				case PortType.spawner:
					port = addPort!(PortType.spawner);
					break;
			}
		}
	}
	
	//---Bridge Functions
	public
	void plugInPorts(Port!isMaster[] port) {
		port.each!(p=>plugInPort(p));
	}
	public
	void plugInPort(Port!isMaster port) {
		assert(_ports.length <= typeof(port.id).max);
		port.id = cast(typeof(port.id)) _ports.length;
		_ports ~= port;
		addPorts_send!(Trgt.clients)(clients, [port.type]);
	}
	
	////@RPC(2)
	////void removePort(size_t index) {
	////	assert(index > 0);
	////	ports_.removeValue(index);
	////}
	////public mixin(defaultSrcMixin("removePort","Src.self"));
	
	mixin PortMixin_WithRPC PortMixin;
}




