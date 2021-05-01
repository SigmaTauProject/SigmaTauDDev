module ship_.net_.ports_.spawner_; 

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import std.typecons;
import treeserial;
import structuredrpc;

import ship_.ports_.spawner_;

import ship_.net_.port_;

class NetSpawnerBranch : NetPort {
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
	void __spawn(SpawnInfo[] spawns) {
		spawn_send!TrgtClients(getWaiters, spawns[0..1]);
		getWaiters.length = 0; getWaiters.assumeSafeAppend;
		spawn_send!TrgtClients(listeners, spawns);
	}
	@RPC!SrcClient(3)
	void __spawn_(SpawnInfo[] spawns) {
		spawn_send!TrgtServer(spawns);
	}
	
	mixin NetPortMixin!(false, NetSpawner);
}

class NetSpawner : NetPort {
	SpawnerPort* port;
	ubyte networkedSpawns;
	Client[] getWaiters;
	Client[] listeners;
	
	this (SpawnerPort* port, ubyte id, ubyte typeID) {
		super(portType!(typeof(this)), id, typeID);
		this.port = port;
	}
	
	override
	void update() {
		if (port.spawns.length - networkedSpawns) {
			spawn_send!TrgtClients(getWaiters, port.spawns[networkedSpawns..networkedSpawns+1]);
			getWaiters.length = 0; getWaiters.assumeSafeAppend;
			spawn_send!TrgtClients(listeners, port.spawns[networkedSpawns..$]);
		}
	}
	override
	void postUpdate() {
		if (networkedSpawns) {
			spawn_send!TrgtClients(getWaiters, port.spawns[0..1]);
			getWaiters.length = 0; getWaiters.assumeSafeAppend;
			assert(port.spawns.length == networkedSpawns);
			spawn_send!TrgtClients(listeners, port.spawns);
			networkedSpawns = 0;
		}
	}
	
	@RPC!SrcClient(3)
	void spawn(SpawnInfo[] spawns) {
		port._spawns ~= spawns;
		networkedSpawns++;
	}
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		if (port.spawns.length)
			spawn_send!TrgtClients([client], port.spawns[0..1]);
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
	
	mixin NetPortMixin!(true, NetSpawnerBranch);
}
