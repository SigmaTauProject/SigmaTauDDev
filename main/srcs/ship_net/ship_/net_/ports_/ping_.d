module ship_.net_.ports_.ping_; 

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import std.typecons;
import treeserial;
import structuredrpc;

import ship_.ports_.ping_;

import ship_.net_.port_;

class NetPingBranch : NetPort {
	Client[] getWaiters;
	Client[] listeners;
	
	this(ubyte id, ubyte typeID) {
		super(portType!(typeof(this)), id, typeID);
	}
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		if (!getWaiters.length && !listeners.length)
			get_send!TrgtServer;
		getWaiters ~= client;
	}
	
	@RPC!SrcClient(1)
	void __listen(Client client) {
		if (!listeners.length)
			listen_send!TrgtServer;
		listeners ~= client;
	}
	
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
		if (!listeners.length)
			unlisten_send!TrgtServer;
	}
	
	@RPC!SrcServer(3)
	void __ping(ubyte pings) {
		ping_send!TrgtClients(getWaiters, 1);
		getWaiters.length = 0; getWaiters.assumeSafeAppend;
		ping_send!TrgtClients(listeners, pings);
	}
	@RPC!SrcClient(3)
	void __ping_(ubyte pings) {
		ping_send!TrgtServer(pings);
	}
	
	mixin NetPortMixin!(false, NetPing);
}

class NetPing : NetPort {
	PingPort* port;
	ubyte networkedPings;
	Client[] getWaiters;
	Client[] listeners;
	
	this (PingPort* port, ubyte id, ubyte typeID) {
		super(portType!(typeof(this)), id, typeID);
		this.port = port;
	}
	
	override
	void update() {
		if (port.pings - networkedPings) {
			ping_send!TrgtClients(getWaiters, 1);
			getWaiters.length = 0; getWaiters.assumeSafeAppend;
			ping_send!TrgtClients(listeners, cast(ubyte) (port.pings - networkedPings));
		}
	}
	override
	void postUpdate() {
		if (networkedPings) {
			ping_send!TrgtClients(getWaiters, 1);
			getWaiters.length = 0; getWaiters.assumeSafeAppend;
			ping_send!TrgtClients(listeners, networkedPings);
			networkedPings = 0;
		}
	}
	
	@RPC!SrcClient(3)
	void ping(ubyte pings) {
		port._pings += pings;
		networkedPings += pings;
	}
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		if (port.pings)
			ping_send!TrgtClients([client], 1);
		else
			getWaiters ~= client;
	}
	
	@RPC!SrcClient(1)
	void __listen(Client client) {
		listeners ~= client;
	}
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
	}
	
	mixin NetPortMixin!(true, NetPingBranch);
}
