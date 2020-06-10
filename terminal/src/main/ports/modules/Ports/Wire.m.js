import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export 
const WirePortType = {
	wireIn	: 1,
	wireOut	: 2,
	wire	: 1 | 2,
}
export
function WirePortBase(wirePortType, t, portType) {
	return class WirePortBase extends Port {
		
		//---Constructors
		constructor() {
			super(portType);
		}
		
		//---Private Members
		data	=	null	;// null when not listening or listening is waiting for starting value
		
		listenWaiters	= []	;
		getWaiters	= []	;
		
		listenRequests	= 0	;
		listeners	= []	;
		
		listening	= false	;
		getting	= false	;// whether a get was requested from the server, and is still waiting
		
		
		//---Messages
		static rpc_get	= [0, ];
		static rpc_listen	= [1, ];
		static rpc_unlisten	= [2, ];
		static rpc_set	= [3, t, ];
		
		//-Get
		get(callback){
			console.assert(wirePortType & WirePortType.wireIn);
			if (this.data != null)
				callback(this.data.payload);
			else {
				if (!(this.listening || this.getting)) {
					this.get_send();
					this.getting = true;
				}
				this.getWaiters.push(callback);
			}
		}
		
		//-Listen & Unlisten
		listenCore(callback, dataCallback=false) {
			console.assert(wirePortType & WirePortType.wireIn);
			this.listenRequests++;
			if (!(this.data == null) && callback != null)
				if (dataCallback)
					callback(this.data);
				else
					callback(this.data.payload);
			else {
				if (!(this.istening)) {
					this.listen_send();
					this.listening = true;
				}
				// else: listening, but data not recived yet to start
				if (dataCallback && callback != null)
					this.listenWaiters.push(callback);
				// else listen callback will be handled via normal method when value is recieved from server
			}
		}
		unlistenCore() {
			console.assert(wirePortType & WirePortType.wireIn);
			console.assert(this.listenRequests > 0);
			this.listenRequests--;
			if (!this.listenRequests) {
				this.unlisten_send();
				this.listening = false;
				this.data = null;
				this.listenWaiters = [];
				console.assert(!this.listeners.length);
			}
		}
		
		//-Direct self listen (hold the value, which changes)
		pullListen(callback) {
			this.listenCore(callback);
		}
		
		//-Change Listen (get callback on every change)
		listen(callback = null) {
			if (callback != null)
				this.listeners.push(callback);
			this.listenCore(callback);
		}
		unlisten(callback = null) {
			if (callback != null)
				this.listeners.splice(this.listeners.indexOf(callback), 1);
			this.unlistenCore();
		}
		
		
		//-Set
		set(v, src=Src.self) {
			console.assert(src == Src.server || wirePortType & WirePortType.wireOut);
			this.listeners.forEach(l=>l(v));
			 if (src != Src.server) 
				this.set_send(v);
			
			if (src == Src.server) {
				if (this.getting) {
					console.assert(this.data == null);
					this.getWaiters.forEach(c=>c(v));
					this.getWaiters = [];
					this.getting = false;
				}
				else console.assert(this.getWaiters.length == 0);
			}
			
			if (this.listening) {
				if (this.data != null) {
					this.data.payload = v;
					console.assert(this.listenWaiters.length == 0);
				}
				else {
					this.data = new Ptr(v);
					this.listenWaiters.forEach(c=>c(this.data));
					this.listenWaiters = [];
				}
			}
			else console.assert(this.listenWaiters.length == 0);
		}
	}
}
export const WirePort	= WirePortBase(WirePortType.wire	, SerialType.float32, PortType.wire	);	portMixin_withRPC(WirePort);
export const WireInPort	= WirePortBase(WirePortType.wireIn	, SerialType.float32, PortType.wireIn	);	portMixin_withRPC(WireInPort);
export const WireOutPort	= WirePortBase(WirePortType.wireOut	, SerialType.float32, PortType.wireOut	);	portMixin_withRPC(WireOutPort);
 
