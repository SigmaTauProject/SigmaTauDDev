import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import {WirePortBase, WirePortType} from "./Wire.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export const SpawnerPort = WirePortBase(WirePortType.wireOut, SerialType.staticArray(SerialType.float32, 2), PortType.spawner);	portMixin_withRPC(SpawnerPort);
 
