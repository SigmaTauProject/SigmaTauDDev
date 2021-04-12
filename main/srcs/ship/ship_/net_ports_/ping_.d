module ship_.net_ports_.ping_; 

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import std.typecons;
import treeserial;
import structuredrpc;

import ship_.ports_.ping_;

import ship_.net_ports_.port_;

abstract
class NetPing : NetPort {
	this() {
		this_!(typeof(this));
	}
	@ConstRead {
		Nullable!ubyte _pings;
		bool _getting;
		ubyte _listening;
	}
	
	mixin(GenerateFieldAccessors);
	
	//---methods
	void get() {}
	void listen() {}
	void unlisten() {}
	
	abstract
	void ping();
	
	alias Branch = NetPingBranch;
	alias Root = NetPingRoot;
}

class NetPingBranch : NetPing {
	Client[] getWaiters;
	Client[] listeners;
	
	this () {
		_getting = false;
		_listening = false;
	}
	
	override
	void ping() {
		_pings = cast(ubyte) (_pings.get + 1);
		if (listening) {
			ping_send!TrgtClients(listeners);
			ping_send!TrgtServer();
		}
	}
	
	override
	void get() {
		if (!getting && !listening) {
			ping_send!TrgtServer();
			_getting = true;
		}
	}
	
	override
	void listen() {
		_listening++;
		if (!listening)
			listen_send!TrgtServer();
	}
	
	override
	void unlisten() {
		_listening--;
	}
	
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		if (!pings.isNull && pings.get) {
			ping_send!TrgtClients([client]);
		}
		else {
			getWaiters ~= client;
			get;
		}
	}
	
	@RPC!SrcClient(1)
	void __listen(Client client) {
		listen;
		listeners ~= client;
		if (!pings.isNull)
			foreach (_; 0..pings.get)
				ping_send!TrgtClients([client]);
	}
	
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		unlisten;
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
	}
	
	@RPC!SrcServer(3)
	void __ping() {
		assert(false, "Unimplemented");
		////if (getWaiters.length) {
		////	__set_getWaiters_send(pings.get);
		////	getWaiters = [];
		////	_getting = false;
		////}
	}
	@RPC!SrcClient(3)
	void __ping_() {
		ping();
	}
	void __ping_getWaiters_send() {
		ping_send!TrgtClients(getWaiters);
	}
	
	void update() {
		if (!listening)
			_pings.nullify;
	}
	
	mixin(GenerateFieldAccessors);
	mixin NetPortMixin!(false, NetPingRoot);
}

class NetPingRoot : NetPing {
	class Connection : NetPingConnection {
		this(Parameters!(NetPingConnection.__ctor) args) {
			super(args);
		}
		
		override
		void onPing() {
			_pings = cast(ubyte) (_pings.get + 1);
			ping_send!(TrgtClients)(getWaiters);
			getWaiters.length = 0;
			ping_send!(TrgtClients)(listeners);
		}
	}
	
	Connection con;
	Client[] getWaiters;
	Client[] listeners;
	
	this (Parameters!(Connection.__ctor) args) {
		con = new Connection(args);
		_pings = con.port.pings;
		_getting = true;
		_listening = true;
	}
	
	override
	@RPC!SrcClient(3)
	void ping() {
		_pings = cast(ubyte) (_pings.get + 1);
		con.ping();
		ping_send!(TrgtClients)(getWaiters);
		getWaiters.length = 0;
		ping_send!TrgtClients(listeners);
	}
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		if (_pings.get)
			ping_send!TrgtClients([client]);
		else
			getWaiters ~= client;
	}
	
	@RPC!SrcClient(1)
	void __listen(Client client) {
		listeners ~= client;
		foreach (_; 0.._pings.get)
			ping_send!TrgtClients([client]);
	}
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
	}
	
	mixin(GenerateFieldAccessors);
	mixin NetPortMixin!(true, NetPingBranch);
}
