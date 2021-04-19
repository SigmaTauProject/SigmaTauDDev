module ship_.net_.ports_.radar_; 

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import std.typecons;
import treeserial;
import structuredrpc;

import ship_.ports_.radar_;

import ship_.net_.port_;

class NetRadarBranch : NetPort {
	RadarEntityObject[]	entityObjects	;
	RadarEntity[]	entities	;
	Client[] getWaiters;
	Client[] listeners;
	
	this(ubyte id) {
		super(portType!(typeof(this)), id);
	}
	
	override
	void update() {
		if (!listeners.length) {
			entityObjects = null;
			entities = null;
		}
	}
	
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		if (entities.ptr) {
			change_send!TrgtClients([client], entityObjects, [], entities);
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
		if (entities.ptr) {
			change_send!TrgtClients([client], entityObjects, [], entities);
		}
	}
	
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
		if (!listeners.length)
			unlisten_send!TrgtServer;
	}
	
	@RPC!SrcServer(3)
	void __change(RadarEntityObject[] newEntities, uint[] removedEntities, RadarEntity[] entities) {
		assert(entities.ptr || !removedEntities.length);
		
		entityObjects ~= newEntities;
		foreach(e; removedEntities)
			entityObjects = entityObjects.remove(e);
		this.entities = entities ;
		
		if (getWaiters.length) {
			assert(!removedEntities.length);
			change_send!TrgtClients(getWaiters, newEntities, removedEntities, entities);
			getWaiters.length = 0;getWaiters.assumeSafeAppend;
		}
		change_send!TrgtClients(listeners, newEntities, removedEntities, entities);
	}
	
	mixin NetPortMixin!(false, NetRadar);
}

class NetRadar : NetPort {
	RadarPort* port;
	Client[] getters;
	Client[] listeners;
	
	this (RadarPort* port, ubyte id) {
		super(portType!(typeof(this)), id);
		this.port = port;
	}
	
	override
	void update() {
		change_send!TrgtClients(listeners, port.newEntities, port.removedEntities, port.entities);
		change_send!TrgtClients(getters, port.entityObjects, [], port.entities);
		getters.length = 0; getters.assumeSafeAppend;
	}
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		getters ~= client;
	}
	
	@RPC!SrcClient(1)
	void __listen(Client client) {
		change_send!TrgtClients(client, port.entityObjects, [], port.entities);
		listeners ~= client;
	}
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
	}
	
	mixin NetPortMixin!(true, NetRadarBranch);
}
