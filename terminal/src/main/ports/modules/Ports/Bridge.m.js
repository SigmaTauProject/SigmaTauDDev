import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import {WirePort, WireInPort, WireOutPort} from "/modules/Ports/Wire.m.js";
import {RadarPort} from "/modules/Ports/Radar.m.js";
import {UnknownPort} from "/modules/Ports/Unknown.m.js";

import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";
import Ptr from "/modules/Ptr.m.js";

import {Slider} from "/modules/Widgets/Slider.m.js";
import {Radar} from "/modules/Widgets/Radar.m.js";

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
			case PortType.wire:
				port = new WirePort(); 
				break;
			case PortType.wireIn:
				port = new WireInPort(); 
				break;
			case PortType.wireOut:
				port = new WireOutPort(); 
				break;
			case PortType.radar:
				port = new RadarPort(); 
				break;
			default:
				port = new UnknownPort(type);
				break;
		}
		this.addNewPortToPorts(port);
	}
	
	addNewPortToPorts(port) {
		console.assert(this.ports.length <= 255);
		port.id = this.ports.length;
		port.server = this.server;
		this.ports.push(port);
		if (port.type == PortType.wire)
			document.body.appendChild(new Slider(port).el);
		else if (port.type == PortType.radar)
			document.body.appendChild(new Radar(port).el);
	}
}

portMixin_withRPC(Bridge);
 
