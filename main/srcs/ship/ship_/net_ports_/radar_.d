module ship_.net_ports_.radar_; 

import accessors;
import std.traits;
import std.algorithm;
import std.range;
import std.bitmanip;
import std.typecons;
import treeserial;
import structuredrpc;

import ship_.ports_.radar_;

import ship_.net_ports_.port_;

abstract
class NetRadar : NetPort {
	this() {
		this_!(typeof(this));
	}
	@ConstRead {
		bool _isNull	;
		RadarEntityObject[] _entityObjects	;
		RadarEntity[] _entities	;
		
		bool _getting;
		ubyte _listening;
	}
	
	mixin(GenerateFieldAccessors);
	
	//---methods
	void get() {}
	void listen() {}
	void unlisten() {}
	
	alias Branch = NetRadarBranch;
	alias Root = NetRadarRoot;
}

class NetRadarBranch : NetRadar {
	Client[] getWaiters;
	Client[] listeners;
	
	this () {
		_getting = false;
		_listening = false;
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
	}
	
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		if (!isNull) {
			update_send!TrgtClients([client], entityObjects, cast(uint[])[], entities);
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
		if (!isNull)
			update_send!TrgtClients([client], entityObjects, [], entities);
	}
	
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		unlisten;
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
	}
	
	@RPC!SrcServer(3)
	void __update(Src)(RadarEntityObject[] newEntities, uint[] removedEntities, RadarEntity[] entities_) {
		static assert (is(Src==SrcServer));
		if (getWaiters.length) {
			__update_getWaiters_send(newEntities, removedEntities, entities_);
			getWaiters = [];
			_getting = false;
		}
		_isNull = false;
		_entityObjects ~= newEntities;
		foreach(e; removedEntities)
			_entityObjects = _entityObjects.remove(e);
		_entities = entities_;
	}
	void __update_getWaiters_send(RadarEntityObject[] newEntities, uint[] removedEntities, RadarEntity[] entities_) {
		update_send!TrgtClients(getWaiters, newEntities, removedEntities, entities_);
	}
	
	void update() {
		////if (!listening)
		////	_value.nullify;
	}
	
	mixin(GenerateFieldAccessors);
	mixin NetPortMixin!(false, NetRadarRoot);
}

class NetRadarRoot : NetRadar {
	class Connection : NetRadarConnection {
		this(Parameters!(NetRadarConnection.__ctor) args) {
			super(args);
		}
		
		override
		void onChange(const RadarEntityObject[] newEntities, uint[] removedEntities) {
			_entityObjects = cast(RadarEntityObject[]) port.entityObjects;
			_entities = cast(RadarEntity[]) port.entities;
			
			update_send!TrgtClients(listeners, newEntities, removedEntities, port.entities);
			
			update_send!TrgtClients(getters~newListeners, entityObjects, [], entities);
			
			getters.length = 0; getters.assumeSafeAppend;
			listeners ~= newListeners;
			newListeners.length = 0; newListeners.assumeSafeAppend;
		}
	}
	
	Connection con;
	Client[] getters;
	Client[] newListeners;
	Client[] listeners;
	
	this (Parameters!(Connection.__ctor) args) {
		con = new Connection(args);
		
		_entityObjects = cast(RadarEntityObject[]) con.port.entityObjects;
		_entities = cast(RadarEntity[]) con.port.entities;
		
		_getting = true;
		_listening = true;
	}
	
	@RPC!SrcClient(0)
	void __get(Client client) {
		getters ~= client;
	}
	
	@RPC!SrcClient(1)
	void __listen(Client client) {
		newListeners ~= client;
	}
	@RPC!SrcClient(2)
	void __unlisten(Client client) {
		if (auto index = listeners.countUntil(client) +1)
			listeners = listeners.remove(index -1);
	}
	
	mixin(GenerateFieldAccessors);
	mixin NetPortMixin!(true, NetRadarBranch);
}
