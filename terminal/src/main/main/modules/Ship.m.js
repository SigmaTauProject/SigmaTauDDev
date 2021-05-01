import {Port, PortType, Src, portMixin_withRPC} from "/modules/Ports/Port.m.js";
import {Bridge} from "/modules/Ports/Bridge.m.js";

import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";
import Ptr from "/modules/Ptr.m.js";

import {Slider} from "/modules/UI/Slider.m.js";
import {Button} from "/modules/UI/Button.m.js";
import {Radar} from "/modules/UI/Radar.m.js";
import {RadarView} from "/modules/UI/RadarView.m.js";
import {RadarSpawner} from "/modules/UI/RadarSpawner.m.js";
import {WireKeys, PingKey} from "/modules/UI/Keys.m.js";

export
class Ship {
	server;
	bridge;
	
	constructor(server) {
		this.server = server;
		this.bridge = new Bridge(server);
		document.body.innerHTML = `<ui-slider />`;
	}
	
	recvMsg(msg) {
		this.bridge.dispatchMsg(new Uint8Array(msg));
	}
} 
