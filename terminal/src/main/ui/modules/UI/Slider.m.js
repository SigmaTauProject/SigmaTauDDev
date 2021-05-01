import {div, Div} from "/modules/Div.m.js";
import {Port, PortType} from "/modules/Ports/Port.m.js";

export
class Slider extends HTMLElement {
	wirePort;
	wireID;
	
	min=-1;
	max=1;
	step=0.01;
	
	constructor() {
		super();
		
		this.wireID = +this.getAttribute("wire") || 0;
		this.min = +(this.getAttribute("min") || this.min);
		this.max = +(this.getAttribute("max") || this.max);
		this.step = +(this.getAttribute("step") || this.step);
		
		////let workingValue = null;
		this.el	= div (	"div", "slider-outer", "verticalSlider-outer",
				div (	"input", "slider","verticalSlider",
					el => this.inputEl = el,
					Div.attributes({type:"range", min:this.min, max:this.max, step:this.step}),
					Div.on("input", ev=>{
						////workingValue = ev.target.value;
						this.wirePort.set(ev.target.value);
						////this.valueEl.innerText=Math.round(ev.target.value*1000)/10+"%";
						////this.valueEl.style.setProperty("--value", (ev.target.value-this.min)/(this.max-this.min)*100+"%");
					}),
					Div.on("change", ev=>{
						////workingValue = null; wirePort.set(ev.target.value);
					}),
				),
				div("div", "slider-value", el=>this.valueEl=el),
			);
		this.appendChild(this.el);
		
		////({unlisten:this.destroy} = wirePort.listen(v => {
		////	////if (workingValue == null) {
		////		input.value = v;
		////		valueEl.innerText=Math.round(v*1000)/10+"%";
		////		valueEl.style.setProperty("--value", (v-min)/(max-min)*100+"%");
		////	////}
		////}));
	}
	
	attachWire(wire, last=null) {
		console.log("attachWire", wire);
		this.wirePort = wire;
		if (!wire) {
			if (last)
				last.unlisten(this.wireValueChanged.bind(this));
			return
		}
		wire.listen(this.wireValueChanged.bind(this));
	}
	
	wireValueChanged(v) {
		console.log("wireValueChanged");
		if (this.inputEl.value != v)
			this.inputEl.value = v;
		this.valueEl.innerText=Math.round(v*1000)/10+"%";
		this.valueEl.style.setProperty("--value", (v-this.min)/(this.max-this.min)*100+"%");
	}
	
	connectedCallback() {
		console.log("connected");
		bridge.attachUI(PortType.wire, this.wireID, this.attachWire.bind(this));
	}
	disconnectedCallback() {
		console.log("disconnected");
		bridge.unattachUI(PortType.wire, this.wireID, this.attachWire.bind(this));
	}
	
	static get observedAttributes() { return ["min", "max", "step",]; }
	attributeChangedCallback(name, oldValue, newValue) {
		this[name] = +newValue;
		console.log(name, oldValue, newValue);
		this.inputEl.setAttribute(name, newValue);
	}
}

customElements.define('ui-slider', Slider);
