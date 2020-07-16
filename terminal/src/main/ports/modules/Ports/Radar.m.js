import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import {WirePortBase, WirePortType} from "./Wire.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export
class RadarEntity {
	constructor(pos, vel) {
		this.pos = pos;
		this.vel = vel;
	}
		
	static serial_pos = SerialType.staticArray(SerialType.float32, 2);
	static serial_ori = SerialType.uint16;
	static serial_vel = SerialType.staticArray(SerialType.float32, 2);
	
	pos;
	ori;
	vel;
}

export
class RadarData {
	constructor(entities) {
		this.entities = entities;
	}
	
	static serial_entities = SerialType.array(SerialType.object(RadarEntity));
	
	entities;
}

export const RadarPort = WirePortBase(WirePortType.wireIn, SerialType.object(RadarData), PortType.radar);	portMixin_withRPC(RadarPort);
 
