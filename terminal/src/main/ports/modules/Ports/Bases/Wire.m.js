import {Port, PortType, Src, portMixin_withRPC} from "../Port.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";
import {gettableMixin} from "./_Gettable.m.js";
import {listenableMixin} from "./_Listenable.m.js";

export
function WirePortBase(T, portType) {
	class WirePortBase extends Port {
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
		
		// Pacing
		last = null;
		toSend = null;
		
		//-Setting
		set(v, src=Src.self) {
			if (src==Src.self) {// Pacing
				let now = Date.now();
				if (this.last == "callback") {
					this.toSend = v;
					return;
				}
				if (this.last !== null && this.last > now-50) {
					this.toSend = v;
					setTimeout(()=>{
						this.last = null;
						this.set(this.toSend, src);
					}, 60-(now-this.last));
					this.last = "callback";
					return;
				}
				this.last = now;
			}
			else {
				this.toSend = v;
			}
			if (this.data != null)
				this.data.payload = v;
			else
				this.data = new Ptr(v);
			
			 if (src != Src.server) 
				this.set_send(v);
			else
				this.dataComing = false;
			
			 if (src == Src.server) 
				this.onGetReady();
			this.listenerCall("doSend");
			if (src == Src.server) 
				this.onListenReady();
			if (!this.numListeners)
				this.data = null;
		}
	}
	
	portMixin_withRPC(WirePortBase);
	gettableMixin(WirePortBase, "doSend", "onGet");
	listenableMixin(WirePortBase, "doSend", "doPullListen", "onListen", "onUnlisten");
	
	return WirePortBase;
}
