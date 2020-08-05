import {div, Div} from "/modules/Div.m.js";

export
class Button {
	el;
	destroy () {}
	
	constructor(pingPort, {}={}) {
		let input;
		this.el	= div (	"button", "button",
				el => input = el,
				Div.on("click", ev=>{pingPort.ping();}),
			);
	}
}

