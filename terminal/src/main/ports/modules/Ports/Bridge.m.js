import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import {WirePort} from "/modules/Ports/Wire.m.js";

import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";
import Ptr from "/modules/Ptr.m.js";

export
class Bridge extends Port {
	
	//---Constructors
	constructor(server) {
		super(PortType.bridge);
		this.ports = [this];
		this.server = server;
	}
	
	//---Private Members
	server	;
	ports	;
	
	//---Bridge Code
	dispatchMsg(msgData) {
		// TODO: Possible crash
		let portID = msgData[0];
		msgData = msgData.slice(1);
		this.ports[portID].rpcRecv(msgData, Src.server);
	}
	
	//---Messages
	static rpc_addPorts	= [0, SerialType.array(SerialType.uint8)];
	
	addPorts(types) {
		types.forEach(t=>this.addPort(t));
	}
	
	addPort(type) {
		let port;
		switch(type) {
			case PortType.bridge:
				console.assert(false);
			case PortType.wireOut:
				port = new WirePort();
				break;
			case PortType.wireIn:
				console.assert(false, "Unimplemented");
			case PortType.radar:
				console.assert(false, "Unimplemented");
		}
		this.addNewPortToPorts(port);
	}
	
	addNewPortToPorts(port) {
		console.assert(this.ports.length <= 255);
		port.id = this.ports.length;
		port.server = this.server;
		this.ports.push(port);
	}
}

portMixin_withRPC(Bridge);
 
