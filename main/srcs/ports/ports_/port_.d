module ports_.port_;

import treeserial;
import structuredrpc;
import std.traits;
import std.algorithm;

import ports_.bridge_;
import ports_.wire_;

public import networking_.terminal_connection_: Client = TerminalConnection;

struct PortClass(alias Class) {
	alias PortClass = Class;
}

enum PortType : ubyte {
	@PortClass!Bridge	bridge	,
	@PortClass!WirePort	wire	,
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
alias TrgtClient = SrcServer;

alias Test = WirePort!false;

abstract
class Port(bool isMaster) {
	PortType type;
	ubyte id;
	
	// this is not a normal constructor because I was having problems calling a templated `super` constructor.
	void this_(This)() {
		// Magic to automatically calculate PortType; using Type and PortClass UDA defined on PortType members.
		static foreach(type; EnumMembers!PortType) {
			static if (getUDAs!(EnumMembers!PortType[[EnumMembers!PortType].countUntil(type)], PortClass!(TemplateOf!This)).length)
				this.type = type;
		}
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
	@RPCSend!TrgtClient
	void _rpcSendClient(Client[] clients, const(ubyte)[] data) {
		clients.each!(t=>t.put(id~data));
	}
	
	static if (!isMaster)
	abstract
	void recvServerMsg(const(ubyte)[] msg);
	abstract
	void recvClientMsg(Client client, const(ubyte)[] msg);
}

mixin template PortMixin_WithRPC() {
	import std.traits;
	import treeserial;
	import structuredrpc;
	
	public mixin MakeRPCReceive!(SrcClient, Client, Serializer!(LengthType!ubyte));
	static if (!isMaster)
		public mixin MakeRPCReceive!(SrcServer, Serializer!(LengthType!ubyte));
	
	alias ThisTemplate = TemplateOf!(typeof(this));
	mixin MakeRPCSendTo!(ThisTemplate!false, TrgtClient, Serializer!(LengthType!ubyte)) S;
	static if (!isMaster)
		mixin MakeRPCSendTo!(ThisTemplate!true, TrgtServer, Client, Serializer!(LengthType!ubyte)) C;
	
	static if (!isMaster)
	public override
	void recvServerMsg(const(ubyte)[] msg) {
		rpcRecv!SrcServer(msg);
	}
	public override
	void recvClientMsg(Client client, const(ubyte)[] msg) {
		rpcRecv!SrcClient(client, msg);
	}
}

