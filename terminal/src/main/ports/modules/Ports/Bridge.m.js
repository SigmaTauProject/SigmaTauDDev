import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import {WirePort} from "/modules/Ports/Wire.m.js";
import {PingOutPort} from "/modules/Ports/Ping.m.js";
import {RadarPort} from "/modules/Ports/Radar.m.js";
import {SpawnerPort} from "/modules/Ports/Spawner.m.js";
import {UnknownPort} from "/modules/Ports/Unknown.m.js";

import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";
import Ptr from "/modules/Ptr.m.js";

import {Slider} from "/modules/UI/Slider.m.js";
import {Button} from "/modules/UI/Button.m.js";
import {Radar} from "/modules/UI/Radar.m.js";
import {RadarView} from "/modules/UI/RadarView.m.js";
import {RadarSpawner} from "/modules/UI/RadarSpawner.m.js";
import {WireKeys, PingKey} from "/modules/UI/Keys.m.js";


////var wirePortKeys = [
////	port=>new WireKeys(port, "KeyN", {negKey:"KeyH",}),
////	port=>new WireKeys(port, "KeyE", {negKey:"Comma",}),
////	port=>new WireKeys(port, "KeyR", {negKey:"KeyW",}),
////];
var wirePortKeys = [
	port=>new WireKeys(port, "KeyN", {negKey:"KeyH",}),
	port=>new WireKeys(port, "KeyE", {negKey:"Comma", step:1}),
	port=>new WireKeys(port, "KeyR", {negKey:"KeyW",}),
];
var pingPortKeys = [
	port=>new PingKey(port, "Space"),
];

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
			case PortType.pingOut:
				port = new PingOutPort(); 
				break;
			case PortType.radar:
				port = new RadarPort(); 
				break;
			case PortType.spawner:
				port = new SpawnerPort(); 
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
		if (port.type == PortType.wire) {
			document.body.appendChild(new Slider(port).el);
			if (wirePortKeys.length)
				wirePortKeys.splice(0,1)[0](port);
		}
		else if (port.type == PortType.radar) {
			window.radar = new Radar();
			radar.el.style.maxHeight = "100vh";
			new RadarView(radar, port);
			document.body.appendChild(radar.el);
		}
		else if (port.type == PortType.spawner) {
			new RadarSpawner(window.radar, port);
		}
		else if (port.type == PortType.pingOut) {
			document.body.appendChild(new Button(port).el);
			if (pingPortKeys.length)
				pingPortKeys.splice(0,1)[0](port);
		}
	}
}

portMixin_withRPC(Bridge);
 
