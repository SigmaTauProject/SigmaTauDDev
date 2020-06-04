module ship_.ports_.bridge_;

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import treeserial;
import structuredrpc;

import ship_.terminal_;

import ship_.ports_.port_;
import ship_.ports_.bridge_;
import ship_.ports_.wire_out_;

class Bridge(bool isMaster) : Port!isMaster {
	private:
	
	//---Fields
	@ConstRead
	Port!isMaster[]	_ports	;
	mixin(GenerateFieldAccessors);
	
	//---Constructors
	public
	this() {
		super(PortType.bridge);
		_ports = [this];
	}
	
	//---Private Members
	Terminal[] terminals;
	
	//---Bridge Code
	public
	void newTerminals(Terminal[] terminals) {
		if (terminals.length)
			addPorts_send!(Trgt.client)(terminals, _ports[1..$].map!(p=>p.type).array);
	}
	public
	void dispatchClientMsg(Terminal terminal, const(ubyte)[] msgData) {
		// TODO: Possible crash
		import std.stdio; msgData.writeln;
		auto portID = msgData.deserialize!ubyte;
		_ports[portID].recvClientMsg(terminal, msgData);
	}
	
	//---Messages
	@RPC(0)
	void addPorts(Src src:Src.server)(PortType[] types) if (src != src.client) {
		types.each!(t=>addPort!src(t));
	}
	
	private {
		void addPort(Src src:Src.server)(PortType type) if (src != src.client) {
			static if (!isMaster) {
				Port!isMaster port;
				final switch(type) {
					case PortType.bridge:
						assert(false);
					case PortType.wireOut:
						port = new WireOutPort!isMaster;
						break;
					case PortType.wireIn:
						assert(false, "Unimplemented");
					case PortType.radar:
						assert(false, "Unimplemented");
				}
				addNewPortToPorts(port);
			}
			else assert(!isMaster);
		}
		
		static if (isMaster)
		public
		template addPort(alias type) {
			static assert(is(typeof(type) == PortType));
			
			alias P = getUDAs!(type, PortClass)[0].PortClass;
			alias ctorOverloads = __traits(getOverloads, P!isMaster, "__ctor");
			
			static foreach (ctor; ctorOverloads)
			auto addPort(Parameters!ctor args) {
				addPorts_send!(Trgt.client)(terminals, [type]);
				auto port = new P!isMaster(args);
				addNewPortToPorts(port);
				return port;
			}
		}
		
		void addNewPortToPorts(Port!isMaster port) {
			assert(_ports.length <= typeof(port.id).max);
			port.id = cast(typeof(port.id)) _ports.length;
			_ports ~= port;
		}
	}
	
	////@RPC(2)
	////void removePort(size_t index) {
	////	assert(index > 0);
	////	ports_.removeValue(index);
	////}
	////public mixin(defaultSrcMixin("removePort","Src.self"));
	
	mixin PortMixin_WithRPC PortMixin;
}




