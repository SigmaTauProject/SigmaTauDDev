module ship_.net_.ports_.wire_; 

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import std.typecons;
import std.math;
import treeserial;
import structuredrpc;

import ship_.ports_.wire_;

import ship_.net_.port_;

class NetWireBranch : NetPort {
	float value;
	Client[] getWaiters;
	Client[] listeners;
	
	this(ubyte id, ubyte typeID) {
		super(portType!(typeof(this)), id, typeID);
	}
	
	override
	void update() {
		if (!listeners.length)
			value = float.nan;
	}
	
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		if (!value.isNaN) {
			set_send!TrgtClients([client], value, client.msgID);
		}
		else {
			getWaiters ~= client;
			get_send!TrgtServer;
		}
	}
	
	@RPC!SrcClient(1)
	void __listen(Client client) {
		if (!listeners.length)
			listen_send!TrgtServer;
		listeners ~= client;
		if (!value.isNaN)
			set_send!TrgtClients([client], value, client.msgID);
	}
	
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
		if (!listeners.length)
			unlisten_send!TrgtServer;
	}
	
	@RPC!SrcServer(3)
	void __set(float n, uint last) {
		assert(false, "Unimplemented");// Needs to only set if no more recent update local/client update.
		////if (getWaiters.length) {
		////	__set_getWaiters_send(value.get);
		////	getWaiters = [];
		////	_getting = false;
		////}
	}
	@RPC!SrcClient(3)
	void __set(float n) {
		if (n != value) {
			value = n;
			set_send!TrgtClients(getWaiters, n, getWaiters.map!(l=>l.msgID).array);
			getWaiters.length = 0; getWaiters.assumeSafeAppend;
			set_send!TrgtClients(listeners, n, listeners.map!(l=>l.msgID).array);
		}
	}
	@RPC!SrcClient(4)
	void __setFor(float n, ubyte frames) {
		assert(false, "Unimplemented");
	}
	////void __set_getWaiters_send(float value) {
	////	set_send!TrgtClients(getWaiters, value, getWaiters.map!(l=>l.msgID).array);
	////}
	
	mixin NetPortMixin!(false, NetWire);
}

class NetWire : NetPort {
	WirePort* port;
	float lastValue;
	Client[] listeners;
	
	float setForValue;
	ubyte setIn = 0;
	float setInTo;
	
	this (WirePort* port, ubyte id, ubyte typeID) {
		super(portType!(typeof(this)), id, typeID);
		this.port = port;
	}
	
	override
	void update() {
		if (port.value != setForValue)
			setIn = 0;
		if (setIn > 0 && --setIn == 0)
			port.setValue(setInTo);
		if (port.value != lastValue) {
			lastValue = port.value;
			set_send!TrgtClients(listeners, port.value, listeners.map!(l=>l.msgID).array);
		}
	}
	
	@RPC!SrcClient(3)
	void set(float n) {
		port.setValue(n);
		port.twitch;
		setIn = 0;
		////if (n != lastValue) {
		////	lastValue = n;
		////	set_send!TrgtClients(listeners, n, listeners.map!(l=>l.msgID).array);
		////}
	}
	@RPC!SrcClient(4)
	void setFor(float n, ubyte frames) {
		setInTo = port.value;
		setIn = frames;
		setForValue = n;
		port.setValue(n);
		port.twitch;
		////if (n != lastValue) {
		////	lastValue = n;
		////	set_send!TrgtClients(listeners, n, listeners.map!(l=>l.msgID).array);
		////}
	}
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		set_send!TrgtClients([client], port.value, client.msgID);
	}
	
	@RPC!SrcClient(1)
	void __listen(Client client) {
		listeners ~= client;
		set_send!TrgtClients([client], port.value, client.msgID);
	}
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
	}
	
	mixin NetPortMixin!(true, NetWireBranch);
}
