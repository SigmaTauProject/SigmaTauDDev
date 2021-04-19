module ship_.net_.port_;

import treeserial;
import structuredrpc;
import std.traits;
import std.algorithm;

import ship_.net_.ports_.bridge_;
import ship_.net_.ports_.wire_;
import ship_.net_.ports_.ping_;
import ship_.net_.ports_.radar_;
import ship_.net_.ports_.spawner_;

public import networking_.terminal_connection_: Client = TerminalConnection;

struct PortClass(alias Class) {
	alias PortClass = Class;
}

// TODO: Remove enum PortType @PortClass as that is done by string of name now.
enum PortType : ubyte {
	@PortClass!NetBridge	bridge	,
	@PortClass!NetWire	wire	,
////	@PortClass!WireInPort	wireIn	,
////	@PortClass!WireOutPort	wireOut	,
	@PortClass!NetPing	ping	= 4,
	@PortClass!NetRadar	radar	= 5,
	@PortClass!NetSpawner	spawner	,
}
mixin(enumMemberUDAFixMixin!"PortType");// Necessary because of D bug #20835
enum enumMemberUDAFixMixin(string enumName) = q{
	static foreach(i; 0..EnumMembers!}~enumName~q{.length)
		pragma(msg, __traits(getAttributes, EnumMembers!}~enumName~q{[i]));
};

enum SrcServer;
enum SrcClient;
enum SrcSelf;
alias TrgtServer = SrcClient;
alias TrgtClients = SrcServer;


abstract
class NetPort {
	const PortType type;
	const ubyte id;
	
	this(PortType type, ubyte id) {
		this.type = type;
		this.id = id;
	}
	
	void update() {}
	void postUpdate() {}
	
	@property
	void* portPointer() {
		assert(false);
	}
	
	auto safeCast(PortType toType)() {
		if (toType==type)
			return cast(PortTypeType!toType) this;
		else
			return null;
	}
	
	@RPCSend!TrgtServer
	void _rpcSendServer(const(ubyte)[] data) {
		import std.stdio;
		writeln("sending to server:", id~data);
		assert(false, "Unimplemented");
	}
	@RPCSend!TrgtClients
	void _rpcSendClient(Client[] clients, const(ubyte)[] data) {
		clients.each!(t=>t.send(id~data));
	}
	
	abstract
	void recvServerMsg(const(ubyte)[] msg);
	abstract
	void recvClientMsg(Client client, const(ubyte)[] msg);
}

template portType(This) {
	// Magic to automatically set PortType; using Type and PortClass UDA defined on PortType members.
	static foreach(type; EnumMembers!PortType) {
		static if (getUDAs!(EnumMembers!PortType[[EnumMembers!PortType].countUntil(type)], PortClass!(This.RootT)).length)
			enum portType = type;
	}
}

mixin template NetPortMixin(bool isRoot, Other) {
	import std.traits;
	import treeserial;
	import structuredrpc;
	
	static if (__traits(hasMember, typeof(this), "port"))
	override @property
	void* portPointer() {
		return this.port;
	}
	
	static if (isRoot) {
		alias RootT = typeof(this);
		alias BranchT = Other;
	}
	else {
		alias RootT = Other;
		alias BranchT = typeof(this);
	}
	
	mixin MakeRPCSendTo!(BranchT, TrgtClients, Serializer!(LengthType!ubyte));
	static if (!isRoot)
		mixin MakeRPCSendTo!(RootT, TrgtServer, Client, Serializer!(LengthType!ubyte));
	
	public mixin MakeRPCReceive!(SrcClient, Client, Serializer!(LengthType!ubyte));
	static if (!isRoot)
		public mixin MakeRPCReceive!(SrcServer, Serializer!(LengthType!ubyte));
	
	static if (!isRoot)
		public override
		void recvServerMsg(const(ubyte)[] msg) {
			rpcRecv!SrcServer(msg);
		}
	else
		public override
		void recvServerMsg(const(ubyte)[] msg) { assert(false); }
	public override
	void recvClientMsg(Client client, const(ubyte)[] msg) {
		rpcRecv!SrcClient(client, msg);
	}
}

