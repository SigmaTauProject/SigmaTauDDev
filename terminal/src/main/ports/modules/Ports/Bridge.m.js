import {Port, PortType, NullPort, Src, portMixin_withRPC} from "./Port.m.js";
import {WirePort} from "/modules/Ports/Wire.m.js";
import {PingOutPort} from "/modules/Ports/Ping.m.js";
import {RadarPort} from "/modules/Ports/Radar.m.js";
import {SpawnerPort} from "/modules/Ports/Spawner.m.js";
import {UnknownPort} from "/modules/Ports/Unknown.m.js";

import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";
import Ptr from "/modules/Ptr.m.js";

////import {Slider} from "/modules/UI/Slider.m.js";
////import {Button} from "/modules/UI/Button.m.js";
////import {Radar} from "/modules/UI/Radar.m.js";
////import {RadarView} from "/modules/UI/RadarView.m.js";
////import {RadarSpawner} from "/modules/UI/RadarSpawner.m.js";
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
		super(PortType.bridge, 0);
		this.allPorts = [this];
		this.ports = {};
		this.server = server;
	}
	
	//---Private Members
	server	;
	allPorts	;
	ports	;
	
	//---Bridge Code
	dispatchMsg(msgData) {
		// TODO: Possible crash
		if (msgData.length == 0)
			return console.error("Network Msg Error: Msg recieved with length 0 (no port ID sent).");
		let portID = msgData[0];
		msgData = msgData.slice(1);
		if (!this.allPorts[portID])
			return console.error("Network Msg Error: Port with portID does not exist.");
		this.allPorts[portID].rpcRecv(msgData, Src.server);
	}
	
	//---Messages
	static rpc_updatePorts	= [0, SerialType.array(SerialType.uint8), SerialType.array(SerialType.tuple(SerialType.uint8,SerialType.uint8))];
	
	attachUI(type, typeID, callback) {
		this.ports[type] ||= [];
		(this.ports[type][typeID] ||= new NullPort()).attachUI(callback);
	}
	unattachUI(type, typeID, callback) {
		this.ports[type][typeID].unattachUI(callback);
	}
	
	updatePorts(removed, added) {
		removed.forEach(r=> {
			this.ports[this.ports[r].typeID];
			this.ports[r].destroy();
			this.ports[r] = new NullPort(...this.ports[r].uis);
		});
		added.forEach(a=>this.addPort(...a));
	}
	
	addPort(type, typeID) {
		let port;
		switch(type) {
			case PortType.bridge:
				console.assert(false);
			case PortType.wire:
				port = new WirePort(typeID); 
				break;
			case PortType.pingOut:
				port = new PingOutPort(typeID); 
				break;
			case PortType.radar:
				port = new RadarPort(typeID); 
				break;
			case PortType.spawner:
				port = new SpawnerPort(typeID); 
				break;
			default:
				port = new UnknownPort(type, typeID);
				break;
		}
		this.addNewPortToPorts(port);
	}
	
	addNewPortToPorts(port) {
		console.assert(this.allPorts.length <= 255);
		//---init
		port.server = this.server;
		//---allPorts
		port.id = this.allPorts.indexOf(null);
		if (port.id == -1) {
			port.id = this.allPorts.length;
			this.allPorts.push(port);
		}
		else {
			this.allPorts[port.id] = port;
		}
		//---ports
		this.ports[port.type] ||= [];
		port.attachUI(...this.ports[port.type][port.typeID]?.uis || []);
		this.ports[port.type][port.typeID] = port;
		
		if (port.type == PortType.wire) {
		////	document.body.appendChild(new Slider(port).el);
			if (wirePortKeys.length)
				wirePortKeys.splice(0,1)[0](port);
		}
		////else if (port.type == PortType.radar) {
		////	window.radar = new Radar();
		////	radar.el.style.maxHeight = "100vh";
		////	new RadarView(radar, port);
		////	document.body.appendChild(radar.el);
		////}
		////else if (port.type == PortType.spawner) {
		////	new RadarSpawner(window.radar, port);
		////}
		////else if (port.type == PortType.pingOut) {
		////	document.body.appendChild(new Button(port).el);
		////	if (pingPortKeys.length)
		////		pingPortKeys.splice(0,1)[0](port);
		////}
	}
}

portMixin_withRPC(Bridge);
 
