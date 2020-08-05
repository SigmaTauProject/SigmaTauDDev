module ports_.radar_;

import accessors;
import structuredrpc;
import ports_.port_;

import std.traits;
import std.algorithm;
import std.range;
import std.typecons;

import ports_.bases_._accessable_;
import ports_.bases_._gettable_;
import ports_.bases_._listenable_;

struct RadarEntityObject {
	float radius;
	float[2][] shape;
}
struct RadarEntity {
	float[2] pos;
	ushort ori;
	float[2] vel;
}

class RadarPort(bool isMaster) : Port!isMaster {
	//---Constructors
	public {
		this() {
			this_!(typeof(this));
		}
	}
	
	//---Private Members
	private {
		RadarEntityObject[]	entityObjects	;
		RadarEntity[]	entities	;
		
		static if (!isMaster)	bool	dataComing	= false	;
		static if (!isMaster)	size_t	listeners	= 0	;
	}
	
	///---Messages
	//-Getting
	
	@RPCGetID(0)
	@RPCListenID(1)
	void doInit(Client[] connections) {
		if (entityObjects.length)
			update_send!TrgtClient(connections, entityObjects, entities);
	}
	void doInit(void delegate(RadarEntityObject[], RadarEntity[])[] connections) {
		if (entityObjects.length)
			connections.each!(con=>con(entityObjects, entities));
	}
	
	void doUpdate(Client[] connections, RadarEntityObject[] newEntities) {
		update_send!TrgtClient(connections, newEntities, entities);
	}
	void doUpdate(void delegate(RadarEntityObject[], RadarEntity[])[] connections, RadarEntityObject[] newEntities) {
		connections.each!(con=>con(newEntities, entities));
	}
	
	static if (isMaster) {
		mixin Gettable!("doInit", onGet) GettableMixin;
		void onGet() {
			onGetReady;
		}
		RadarEntityObject[] getEntityObjects() {
			return entityObjects;
		}
		RadarEntity[] getEntities() {
			return entities;
		}
	}
	else {
		mixin Gettable!("doInit", onGet);
		void onGet() {
			onGetReady;
			if (!entityObjects.length && !dataComing) {
				get_send!TrgtServer;
				dataComing = true;
			}
		}
	}
	
	//-Listening
	static if (isMaster) {
		mixin Listenable!("doInit", onListen, onUnlisten);
		void onListen() {
			onListenReady;
		}
		void onUnlisten() {
		}
	}
	else {
		mixin Listenable!("doInit", onListen, onUnlisten);
		void onListen() {
			onListenReady;
			if (!entityObjects.length && !listeners) {
				listen_send!TrgtServer;
				dataComing = true;
			}
			listeners++;
		}
		void onUnlisten() {
			listeners--;
			if (!listeners) {
				unlisten_send!TrgtServer;
				entityObjects = [];
				entities = [];
			}
		}
	}
	
	//-Setting
	@RPC!SrcServer(3)
	void update(RadarEntityObject[] newEntities, RadarEntity[] entities_) {
		entityObjects ~= newEntities;
		entities = entities_;
		static if(!isMaster)
			dataComing = false;
		listenerCall!"doUpdate"(newEntities);
		static if (!isMaster) if (!listeners) {
			entityObjects = [];
			entities = [];
		}
	}
	
	mixin PortMixin_WithRPC;
}
