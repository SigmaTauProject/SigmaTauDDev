import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import {MsgOutPortBase} from "./Bases/MsgOut.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export const SpawnerPort	= MsgOutPortBase(SerialType.staticArray(SerialType.float32, 2), PortType.spawner);
 
