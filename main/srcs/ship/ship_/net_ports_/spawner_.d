module ship_.net_ports_.spawner_; 

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import std.typecons;
import treeserial;
import structuredrpc;

import ship_.ports_.spawner_;

import ship_.net_ports_.port_;

abstract
class NetSpawner : NetPort {
	this() {
		this_!(typeof(this));
	}
	@ConstRead {
		////Nullable!(SpawnInfo[]) _spawns;
		////bool _getting;
		////ubyte _listening;
	}
	
	mixin(GenerateFieldAccessors);
	
	//---methods
	////void get() {}
	////void listen() {}
	////void unlisten() {}
	
	abstract
	void spawn(SpawnInfo info);
	
	alias Branch = NetSpawnerBranch;
	alias Root = NetSpawnerRoot;
}

class NetSpawnerBranch : NetSpawner {
	////Client[] getWaiters;
	////Client[] listeners;
	
	this () {
		////_getting = false;
		////_listening = false;
	}
	
	@RPC!SrcServer(3)
	override
	void spawn(SpawnInfo info) {
		spawn_send!TrgtServer(info);
	}
	
	////override
	////void get() {
	////	assert(false, "Unimplemented");
	////	////if (!getting && !listening) {
	////	////	get_send!TrgtServer();
	////	////	_getting = true;
	////	////}
	////}
	////
	////override
	////void listen() {
	////	_listening++;
	////	if (!listening)
	////		listen_send!TrgtServer();
	////}
	////
	////override
	////void unlisten() {
	////	_listening--;
	////}
	
	
	////@RPC!SrcClient(0)
	////void __get(Client client) {
	////	if (!spawns.isNull && spawns.get.length) {
	////		spawn_send!TrgtClients([client], spawns.get[0]);
	////	}
	////	else {
	////		getWaiters ~= client;
	////		get;
	////	}
	////}
	////
	////@RPC!SrcClient(1)
	////void __listen(Client client) {
	////	listen;
	////	listeners ~= client;
	////	if (!spawns.isNull)
	////		foreach (info; spawns.get)
	////			spawn_send!TrgtClients([client], info);
	////}
	////
	////@RPC!SrcClient(2)
	////void __unlisten(Client client) {
	////	unlisten;
	////	if (auto index = listeners.countUntil(client) +1)
	////		listeners = listeners.remove(index -1);
	////}
	
	////@RPC!SrcServer(3)
	////void __spawn(SpawnInfo info) {
	////	assert(false, "Unimplemented");
	////	////if (getWaiters.length) {
	////	////	__set_getWaiters_send(spawns.get);
	////	////	getWaiters = [];
	////	////	_getting = false;
	////	////}
	////}
	////@RPC!SrcClient(3)
	////void __spawn_(SpawnInfo info) {
	////	spawn(info);
	////}
	
	void update() {
		////if (!listening)
		////	_spawns.nullify;
	}
	
	mixin(GenerateFieldAccessors);
	mixin NetPortMixin!(false, NetSpawnerRoot);
}

class NetSpawnerRoot : NetSpawner {
	class Connection : NetSpawnerConnection {
		this(Parameters!(NetSpawnerConnection.__ctor) args) {
			super(args);
		}
	}
	
	Connection con;
	////Client[] getWaiters;
	////Client[] listeners;
	
	this (Parameters!(Connection.__ctor) args) {
		con = new Connection(args);
		////_spawns = con.port.spawns;
		////_getting = true;
		////_listening = true;
	}
	
	@RPC!SrcClient(3)
	override
	void spawn(SpawnInfo info) {
		////_spawns = _spawns.get ~ info;
		con.spawn(info);
		////spawn_send!(TrgtClients)(getWaiters, info);
		////getWaiters.length = 0;
		////spawn_send!TrgtClients(listeners, info);
	}
	
	////@RPC!SrcClient(0)
	////void __get(Client client) {
	////	if (_spawns.get.length)
	////		spawn_send!TrgtClients([client], _spawns.get[0]);
	////	else
	////		getWaiters ~= client;
	////}
	////
	////@RPC!SrcClient(1)
	////void __listen(Client client) {
	////	listeners ~= client;
	////	foreach (info; _spawns.get)
	////		spawn_send!TrgtClients([client], info);
	////}
	////@RPC!SrcClient(2)
	////void __unlisten(Client client) {
	////	if (auto index = listeners.countUntil(client) +1)
	////		listeners = listeners.remove(index -1);
	////}
	
	mixin(GenerateFieldAccessors);
	mixin NetPortMixin!(true, NetSpawnerBranch);
}
