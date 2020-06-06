import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import {WirePortBase, WirePortType} from "./Wire.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export
class RadarData {
	constructor(entities) {
		this.entities = entities;
	}
	
	static serial_entities = SerialType.array(SerialType.staticArray(SerialType.float32, 2));
	
	entities;
}

export const RadarPort = WirePortBase(WirePortType.wireIn, SerialType.object(RadarData));	portMixin_withRPC(RadarPort);
 
