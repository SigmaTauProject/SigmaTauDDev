import {Port, PortType, Src, portMixin_withRPC} from "../Port.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export
function MsgOutPortBase(T, portType) {
	class MsgOutPortBase extends Port {
		//---Constructors
		constructor() {
			super(portType);
		}
		
		//---Private Members
		
		///---Messages
		static rpc_send	= [3, T, ];
		
		//-Getting & Listening
		
		//-Setting
		send(v, src=Src.self) {
			this.send_send(v);
		}
		
	}
	portMixin_withRPC(MsgOutPortBase);
	return MsgOutPortBase;
}
