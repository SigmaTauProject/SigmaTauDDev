import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export
class PingOutPort extends Port {
	//---Constructors
	constructor() {
		super(PortType.pingOut);
	}
	
	//---Private Members
	
	///---Messages
	static rpc_ping	= [3, SerialType.uint8];
	
	//-Getting & Listening
	
	//-Setting
	ping(src=Src.self) {
		this.ping_send(1);
	}
	
}
portMixin_withRPC(PingOutPort);
