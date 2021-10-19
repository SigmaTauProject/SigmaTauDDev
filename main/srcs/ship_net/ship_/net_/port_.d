module ship_.net_.port_;

import treeserial;
import structuredrpc;
import std.traits;
import std.algorithm;

import ship_.components_.bridge_: portNames;
static foreach (portName; portNames) {
	mixin("import ship_.net_.ports_."~portName~"_;");
}

public import networking_.terminal_connection_: Client = TerminalConnection;

enum PortType : ubyte {
	bridge	,
	wire	,
////	wireIn	,
////	wireOut	,
	ping	= 4,
	radar	= 5,
	spawner	,
}

enum SrcServer;
enum SrcClient;
enum SrcSelf;
alias TrgtServer = SrcClient;
alias TrgtClients = SrcServer;


abstract
class NetPort {
	const PortType type;
	const ubyte id;
	const ubyte typeID;
	
	this(PortType type, ubyte id, ubyte typeID) {
		this.type = type;
		this.id = id;
		this.typeID = typeID;
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

template portType(This) if (__traits(identifier, This)[0..3] == "Net" && is(This : NetPort)) {
	import std.ascii;
	// Magic to automatically set PortType; using Type and PortClass UDA defined on PortType members.
	static if (__traits(identifier, This)[$-6..$] == "Branch")
		enum portType = mixin("PortType."~__traits(identifier, This)[3].toLower ~ __traits(identifier, This)[4..$-6]);
	else
		enum portType = mixin("PortType."~__traits(identifier, This)[3].toLower ~ __traits(identifier, This)[4..$]);
}
template PortTypeType(PortType type) {
	import std.ascii; import std.conv;
	alias PortTypeType = mixin("Net"~x.to!string[0].toUpper ~ x.to!string[1..$]);
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

