import {Port, PortType, Src, portMixin_withRPC} from "../Port.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";
import {gettableMixin} from "./_Gettable.m.js";
import {listenableMixin} from "./_Listenable.m.js";

export
function WireInPortBase(T, portType) {
	class WireInPortBase extends Port {
		//---Constructors
		constructor() {
			super(portType);
		}
		
		//---Private Members
		data	= null	;// null when not listening or listening is waiting for starting value
				
		dataComing	= false	;
		numListeners	= 0	;
		
		///---Messages
		static rpc_get	= [0, ];
		static rpc_listen	= [1, ];
		static rpc_unlisten	= [2, ];
		static rpc_set	= [3, T, ];
		
		//-Getting
		
		doSend(callbacks) {
			callbacks.forEach(c=>c(this.data.payload));
		}
		
		onGet() {
			if (this.data != null)
				this.onGetReady();
			else if (!this.dataComing) {
				this.get_send();
				this.dataComing = true;
			}
		}
		
		//-Listening
		doPullListen(callbacks) {
			callbacks.forEach(c=>c(this.data));
		}
		onListen() {
			if (this.data != null)
				this.onListenReady();
			else if (!this.numListeners)  {
				this.listen_send();
				this.dataComing = true;
			}
			this.numListeners++;
		}
		onUnlisten() {
			this.numListeners--;
			if (!this.numListeners) {
				this.unlisten_send();
				this.data = null;
			}
		}
		
		//-Setting
		set(v, src=Src.self) {
			if (this.data != null)
				this.data.payload = v;
			else
				this.data = new Ptr(v);
			
			 this.dataComing = false;
			
			this.onGetReady();
			this.listenerCall("doSend");
			this.onListenReady();
			
			if (!this.numListeners)
				this.data = null;
		}
	}
	
	portMixin_withRPC(WireInPortBase);
	gettableMixin(WireInPortBase, "doSend", "onGet", 0);
	listenableMixin(WireInPortBase, "doSend", "doPullListen", "onListen", "onUnlisten");
	
	return WireInPortBase;
}
