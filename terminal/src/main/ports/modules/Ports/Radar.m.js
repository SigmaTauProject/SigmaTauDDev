import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";
import {gettableMixin} from "./Bases/_Gettable.m.js";
import {listenableMixin} from "./Bases/_Listenable.m.js";

export
class RadarEntityObject {
	static serial_radius = SerialType.float32;
	static serial_shape = SerialType.array(SerialType.staticArray(SerialType.float32, 2));
	
	radius;
	shape;
}
export
class RadarEntity {
	static serial_pos = SerialType.staticArray(SerialType.float32, 2);
	static serial_ori = SerialType.uint16;
	static serial_vel = SerialType.staticArray(SerialType.float32, 2);
	
	pos;
	ori;
	vel;
}

export
class RadarPort extends Port {
	//---Constructors
	constructor() {
		super(PortType.radar);
	}
	
	//---Private Members
	entityObjects	= []	;
	entities	= []	;
			
	dataComing	= false	;
	numListeners	= 0	;
	
	///---Messages
	static rpc_get	= [0, ];
	static rpc_listen	= [1, ];
	static rpc_unlisten	= [2, ];
	static rpc_update	= [3, SerialType.array(SerialType.struct(RadarEntityObject)), SerialType.array(SerialType.uint32), SerialType.array(SerialType.struct(RadarEntity))];
	
	//-Getting
	doInit(callbacks) {
		callbacks.forEach(c=>c(this.entityObjects, [], this.entities));
	}
	doUpdate(callbacks, newEntities, removedEntities) {
		callbacks.forEach(c=>c(newEntities, removedEntities, this.entities));
	}
	
	onGet() {
		if (this.entityObjects.length)
			this.onGetReady();
		else if (!this.dataComing) {
			this.get_send();
			this.dataComing = true;
		}
	}
	
	//-Listening
	doPullListen(callbacks) {
		console.assert(false);
	}
	onListen() {
		if (this.entityObjects.length)
			this.onListenReady();
		else if (!this.numListeners)  {
			this.listen_send();
			this.dataComing = true;
		}
		this.numListeners++;
	}
	onUnlisten() {
		this.numListeners--;
		if (!this.numListeners) {
			this.unlisten_send();
			this.entityObjects = [];
			this.entities = [];
		}
	}
	
	//-Setting
	update(newEntities, removedEntities, entities) {
		this.entityObjects.push(...newEntities);
		for (let e of removedEntities)
			this.entityObjects.splice(e,1);
		this.entities = entities;
		
		this.dataComing = false;
		
		this.onGetReady();
		this.listenerCall("doUpdate", newEntities, removedEntities);
		this.onListenReady();
		
		if (!this.numListeners) {
			this.entityObjects = [];
			this.entities = [];
		}
	}
}

portMixin_withRPC(RadarPort);
gettableMixin(RadarPort, "doInit", "onGet");
listenableMixin(RadarPort, "doInit", "doPullListen", "onListen", "onUnlisten");



