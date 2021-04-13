import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";
import Ptr from "/modules/Ptr.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";


class WirePortRoot {
	static rpc_get	= [0, ];
	static rpc_listen	= [1, ];
	static rpc_unlisten	= [2, ];
	static rpc_set	= [3, SerialType.float32, ];
}

export
class WirePort extends Port {
	constructor () {
		super(PortType.wire);
	}
	
	data	= null	;
			
	getters	= []	;
	listeners	= []	;
	pullListeners	= []	;
	
	lastSetMsgID = null;
	
	static rpc_remote_set	= [3, SerialType.float32, SerialType.uint32, ];
	
	get(callback) {
		if (this.data !== null) {
			callback(this.data.payload);
		}
		else {
			this.get_send();
			this.getters.push(callback);
		}
	}
	
	listen(callback) {
		if (this.data !== null) {
			callback(this.data.payload);
		}
		if (!this.listeners.length && !this.pullListeners.length)
			this.listen_send();
		this.listeners.push(callback);
		return ()=>unlisten(callback);
	}
	unlisten(callback) {
		let index = this.listeners.indexOf(callback);
		console.assert(index != -1);
		if (true) {
			this.listeners.splice(index, 1);
			this.checkUnlisten();
		}
	}
	
	pullListen(callback) {
		if (this.data !== null) {
			callback(this.data);
			this.pullListeners.push(null);
		}
		else {
			if (!this.listeners.length && !this.pullListeners.length)
				this.listen_send();
			this.pullListeners.push(callback);
		}
		return ()=>pullUnlisten(callback);
	}
	pullUnlisten(callback) {
		if (data !== null) {
			this.pullListeners.length--;
			this.checkUnlisten();
		}
		else {
			let index = this.pullListeners.indexOf(callback);
			console.assert(index != -1);
			if (true) {
				this.pullListeners.splice(index, 1);
				this.checkUnlisten();
			}
		}
	}
	
	checkUnlisten() {
		if (!this.listeners.length && !this.pullListeners.length) {
			this.unlisten_send();
			this.data = null;
		}
	}
	
	// Pacing
	last = null;
	
	set(n) {
		if (this.data !== null)
			this.data.payload = n;
		
		this.listeners.forEach(c=>c(n));
		
		{// Pacing
			// TODO: if an old value is received from the server while holding, the held value will get overridden and never sent.
			let now = Date.now();
			if (this.last == "callback") {
				return;
			}
			if (this.last !== null && this.last > now-50) {
				setTimeout(()=>{
					this.last = Date.now();
					if (this.data !== null) {
						this.set_send(this.data.payload);
						this.lastSetMsgID = this.server.sentMsgID;
					}
				}, 60-(now-this.last));
				this.last = "callback";
				return;
			}
			this.last = now;
			
			this.set_send(n);
			this.lastSetMsgID = this.server.sentMsgID;
		}
	}
	remote_set(n, last) {
		if (this.lastSetMsgID > last) {
			return;
		}
	}
	remote_set(n) {
		if (this.data !== null) {
			this.data.payload = n;
		}
		else if (this.listeners.length || this.pullListeners.length) {
			this.data = new Ptr(n);
			this.pullListeners = this.pullListeners.map(c=>{
				c(this.data);
				return null;
			});
		}
		
		this.getters.forEach(c=>c(n));
		this.getters = [];
		this.listeners.forEach(c=>c(n));
	}
}
portMixin_withRPC(WirePort, WirePortRoot);
