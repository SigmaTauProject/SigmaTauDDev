module ship_.ports_.port_;

import treeserial;
import structuredrpc;
import std.traits;
import std.algorithm;

import ship_.ports_.bridge_;
import ship_.ports_.wire_;

public import ship_.terminal_;

struct PortClass(alias Class) {
	alias PortClass = Class;
}

enum PortType : ubyte {
	@PortClass!Bridge	bridge	,
	@PortClass!WirePort	wire	,
		wireIn	,
}
mixin(enumMemberUDAFixMixin!"PortType");// Necessary because of D bug #20835

enum Src : ubyte {
	server	= 0x1	,
	self	= 0x2	,
	@RPCCon!Terminal
	client	= 0x4	,
}
enum Trgt : ubyte {
	@RPCCon!Terminal
	client	= 0x1	,
	self	= 0x2	,
	server	= 0x4	,
}

abstract
class Port(bool isMaster) {
	PortType type;
	ubyte id;
	
	static if (isMaster)
	this(PortType type) {
		this.type = type;
	}
	
	auto safeCast(PortType toType)() {
		if (toType==type)
			return cast(PortTypeType!toType) this;
		else
			return null;
	}
	
	void rpcSend(Trgt trgt:Trgt.server)(const(ubyte)[] data) {
		import std.stdio;
		writeln("sending to server:", id~data);
		assert(false, "Unimplemented");
	}
	void rpcSend(Trgt trgt:Trgt.client)(Terminal[] terminals, const(ubyte)[] data) {
		terminals.each!(t=>t.send(id~data));
	}
	
	abstract
	void recvServerMsg(const(ubyte)[] msg);
	abstract
	void recvClientMsg(Terminal terminal, const(ubyte)[] msg);
}

mixin template PortMixin_WithRPC() {
	import std.traits;
	import treeserial;
	import structuredrpc;
	mixin(enumMemberUDAFixMixin!"Src");// Necessary because of D bug #20835
	mixin(enumMemberUDAFixMixin!"Trgt");// Necessary because of D bug #20835
	public mixin MakeRPCs!(Src, Trgt, Serializer!(LengthType!ubyte));
	
	public override
	void recvServerMsg(const(ubyte)[] msg) {
		rpcRecv!(Src.server)(msg);
	}
	public override
	void recvClientMsg(Terminal terminal, const(ubyte)[] msg) {
		rpcRecv!(Src.client)(terminal, msg);
	}
}

