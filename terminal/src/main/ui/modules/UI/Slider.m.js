import {div, Div} from "/modules/Div.m.js";
import {Port, PortType} from "/modules/Ports/Port.m.js";
import {UIWithPort} from "../UI.m.js";

export
class Slider extends UIWithPort {
	min=-1;
	max=1;
	step=0.01;
	
	static portType = PortType.wire;
	
	constructor() {
		super();
		
		this.min = +(this.getAttribute("min") || this.min);
		this.max = +(this.getAttribute("max") || this.max);
		this.step = +(this.getAttribute("step") || this.step);
		
		this.el	= div (	"div", "slider-outer", "verticalSlider-outer",
				div (	"input", "slider","verticalSlider",
					el => this.inputEl = el,
					Div.attributes({type:"range", min:this.min, max:this.max, step:this.step}),
					Div.on("input", ev=>{
						this.port?.set(ev.target.value);
					}),
				),
				div("div", "slider-value", el=>this.valueEl=el),
			);
		this.appendChild(this.el);
	}
	
	portListenCallback(v) {
		console.log("Wire value changed.");
		if (this.inputEl.value != v)
			this.inputEl.value = v;
		this.valueEl.innerText=Math.round(v*1000)/10+"%";
		this.valueEl.style.setProperty("--value", (v-this.min)/(this.max-this.min)*100+"%");
	}
	
	static get observedAttributes() { return ["min", "max", "step",]; }
	attributeChangedCallback(name, oldValue, newValue) {
		this[name] = +newValue;
		console.log(name, oldValue, newValue);
		this.inputEl.setAttribute(name, newValue);
	}
}

customElements.define('ui-slider', Slider);
