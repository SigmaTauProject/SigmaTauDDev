import {div, Div} from "/modules/Div.m.js";
import {Port, PortType} from "/modules/Ports/Port.m.js";
import {UIWithPort} from "../UI.m.js";

export
class WireKeys extends UIWithPort {
	static portType = PortType.wire;
	
	value = 0;
	keyDown = false;
	negKeyDown = false;
	
	// Attributes
	get max() { return +this.getAttribute("max"); }	set max(v) { return this.setAttribute("max", v); }	
	get min() { return +this.getAttribute("min"); }	set min(v) { return this.setAttribute("min", v); }	
	get step() { return +this.getAttribute("step"); }	set step(v) { return this.setAttribute("step", v); }	
	get snap() { return +this.getAttribute("snap"); }	set snap(v) { return this.setAttribute("snap", v); }	
	get key() { return this.getAttribute("key"); }	set key(v) { return this.setAttribute("key", v); }	
	get negKey() { return this.getAttribute("negKey"); }	set negKey(v) { return this.setAttribute("negKey", v); }	
	
	constructor(wirePort, key) {
		super();
		
		this.getAttribute("max") ?? (this.max = 1);
		this.getAttribute("min") ?? (this.min = -1);
		this.getAttribute("step") ?? (this.step = 0.1);
		this.getAttribute("snap") ?? (this.snap = 0);
		
		window.addEventListener("keydown",(ev)=>{
			if (ev.code == this.key)
				this.keyDown = true;
			else if (ev.code == this.negKey)
				this.negKeyDown = true;
		});
		window.addEventListener("keyup",(ev)=>{
			if (ev.code == this.key) {
				this.keyDown = false;
				if (this.port) if ((this.max>this.snap && this.value>this.snap) || (this.max<this.snap && this.value<this.snap))
					this.port.set(this.snap);
				ev.preventDefault();
			}
			else if (ev.code == this.negKey) {
				this.negKeyDown = false;
				if (this.port) if ((this.min>this.snap && this.value>this.snap) || (this.min<this.snap && this.value<this.snap))
					this.port.set(this.snap);
				ev.preventDefault();
			}
		});
	}
	
	portListenCallback(v) {
		this.value = v;
	}
	
	update() {
		if (!this.port)
			return;
		let mod;
		if (this.keyDown && this.negKeyDown)
			this.port.set(0);
		else if ((mod = this.max*this.keyDown + this.min*this.negKeyDown) != 0)
			this.port.set(Math.max(this.min, Math.min(this.max,this.value + mod * this.step)));
	}
	
}
customElements.define('ui-wire-keys', WireKeys);

export
class PingKey extends UIWithPort {
	static portType = PortType.pingOut;
	
	// Attributes
	get key() { return this.getAttribute("key"); }	set key(v) { return this.setAttribute(v); }	
	
	constructor() {
		super();
		
		window.addEventListener("keydown",(ev)=>{
			if (ev.code == this.key) {
				if (this.port)
					this.port.ping();
				ev.preventDefault();
			}
		});
	}
}
customElements.define('ui-ping-key', PingKey);




