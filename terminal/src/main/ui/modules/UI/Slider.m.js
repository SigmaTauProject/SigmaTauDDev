import {div, Div} from "/modules/Div.m.js";

export
class Slider {
	el;
	destroy;
	
	constructor(wirePort, {min=-1,max=1,step=0.01}={}) {
		let input;
		let workingValue = null;
		this.el	= div (	"div", "slider-outer", "verticalSlider-outer",
				div (	"input", "slider","verticalSlider",
					el => input = el,
					Div.attributes({type:"range", min:min, max:max, step:step}),
					Div.on("input", ev=>{workingValue = ev.target.value; wirePort.set(ev.target.value);}),
					Div.on("change", ev=>{workingValue = null; wirePort.set(ev.target.value);}),
				),
			);
		({unlisten:this.destroy} = wirePort.listen(v => {if (workingValue == null) input.value = v;}));
	}
}

