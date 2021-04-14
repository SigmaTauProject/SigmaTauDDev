import {div, Div} from "/modules/Div.m.js";

export
class Slider {
	el;
	destroy;
	
	constructor(wirePort, {min=-1,max=1,step=0.01}={}) {
		let input;
		////let workingValue = null;
		let valueEl;
		this.el	= div (	"div", "slider-outer", "verticalSlider-outer",
				div (	"input", "slider","verticalSlider",
					el => input = el,
					Div.attributes({type:"range", min:min, max:max, step:step}),
					Div.on("input", ev=>{
						////workingValue = ev.target.value;
						wirePort.set(ev.target.value);
						valueEl.innerText=Math.round(ev.target.value*1000)/10+"%";
						console.log((ev.target.value-min)/(max-min)*100+"%");
						valueEl.style.setProperty("--value", (ev.target.value-min)/(max-min)*100+"%");
					}),
					Div.on("change", ev=>{
						////workingValue = null; wirePort.set(ev.target.value);
					}),
				),
				div("div", "slider-value", el=>valueEl=el),
			);
		({unlisten:this.destroy} = wirePort.listen(v => {
			////if (workingValue == null) {
				input.value = v;
				valueEl.innerText=Math.round(v*1000)/10+"%";
				valueEl.style.setProperty("--value", (v-min)/(max-min)*100+"%");
			////}
		}));
	}
}

