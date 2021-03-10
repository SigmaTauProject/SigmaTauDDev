module ship_.net_ports_.wire_; 

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import std.typecons;
import treeserial;
import structuredrpc;

import ship_.ports_.wire_;

import ship_.net_ports_.port_;

abstract
class NetWire : NetPort {
	this() {
		this_!(typeof(this));
	}
	@ConstRead {
		Nullable!float _value;
		bool _getting;
		ubyte _listening;
	}
	
	mixin(GenerateFieldAccessors);
	
	//---methods
	void get() {}
	void listen() {}
	void unlisten() {}
	
	abstract
	void set(float n);
	
	alias Branch = NetWireBranch;
	alias Root = NetWireRoot;
}

class NetWireBranch : NetWire {
	Client[] getWaiters;
	Client[] listeners;
	
	this () {
		_getting = false;
		_listening = false;
	}
	
	override
	void set(float v) {
		_value = v;
		if (listening) {
			set_send!TrgtClients(listeners, value.get);
			set_send!TrgtServer(value.get);
		}
	}
	
	override
	void get() {
		if (!getting && !listening) {
			get_send!TrgtServer();
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
		if (!listening)
			_value.nullify;
	}
	
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		if (value.isNull) {
			set_send!TrgtClients([client], value);
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
		if (value.isNull)
			set_send!TrgtClients([client], value);
	}
	
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		unlisten;
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
	}
	
	@RPC!SrcClient(3) @RPC!SrcServer(3)
	void __set(Src)(float n) {
		set(n);
		static if (is(Src==SrcServer)) if (getWaiters.length) {
			__set_getWaiters_send(value);
			getWaiters = [];
			_getting = false;
		}
	}
	void __set_getWaiters_send(float value) {
		set_send!TrgtClients(getWaiters, value);
	}
	
	void update() {
		if (!listening)
			_value.nullify;
	}
	
	mixin NetPortMixin!(false, NetWireRoot);
}

class NetWireRoot : NetWire {
	class Connection : NetWireConnection {
		this(Parameters!(NetWireConnection.__ctor) args) {
			super(args);
		}
		
		override
		void onSetValue() {
			set_send!(TrgtClients)(listeners, port.value);
		}
	}
	
	Connection con;
	Client[] listeners;
	
	this (Parameters!(Connection.__ctor) args) {
		con = new Connection(args);
		_value = con.port.value;
		_getting = true;
		_listening = true;
	}
	
	override
	@RPC!SrcClient(3)
	void set(float n) {
		_value = n;
		con.setValue(n);
		set_send!TrgtClients(listeners, value);
	}
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		set_send!TrgtClients([client], value);
	}
	
	@RPC!SrcClient(1)
	void __listen(Client client) {
		listeners ~= client;
		set_send!TrgtClients([client], value);
	}
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
	}
	
	mixin(GenerateFieldAccessors);
	mixin NetPortMixin!(true, NetWireBranch);
}
