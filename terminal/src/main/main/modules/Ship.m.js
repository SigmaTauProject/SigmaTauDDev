import {Port, PortType, Src, portMixin_withRPC} from "/modules/Ports/Port.m.js";
import {Bridge} from "/modules/Ports/Bridge.m.js";

import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";
import Ptr from "/modules/Ptr.m.js";

export
class Ship {
	server;
	bridge;
	
	constructor(server) {
		this.server = server;
		this.bridge = new Bridge(server);
	}
	
	recvMsg(msg) {
		this.bridge.dispatchMsg(new Uint8Array(msg));
	}
} 
