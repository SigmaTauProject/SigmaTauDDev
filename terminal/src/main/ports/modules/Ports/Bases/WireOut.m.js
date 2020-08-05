import {Port, PortType, Src, portMixin_withRPC} from "../Port.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export
function WireOutPortBase(T, portType) {
	class WireOutPortBase extends Port {
		//---Constructors
		constructor() {
			super(portType);
		}
		
		//---Private Members
		
		///---Messages
		static rpc_set	= [3, T, ];
		
		//-Getting & Listening
		
		//-Setting
		set(v, src=Src.self) {
			this.set_send(v);
		}
		
	}
	portMixin_withRPC(WireOutPortBase);
	return WireOutPortBase;
}
