import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import {WirePortBase} from "./Bases/Wire.m.js";
import {WireOutPortBase} from "./Bases/WireOut.m.js"; 
import {WireInPortBase} from "./Bases/WireIn.m.js"; 
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export const WirePort	= WirePortBase	(SerialType.float32, PortType.wire	);
export const WireOutPort	= WireOutPortBase	(SerialType.float32, PortType.wireOut	);
export const WireInPort	= WireInPortBase	(SerialType.float32, PortType.wireIn	);
