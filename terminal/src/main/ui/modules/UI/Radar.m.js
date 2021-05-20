import {div, svg, Div} from "/modules/Div.m.js";
import {Port, PortType} from "/modules/Ports/Port.m.js";
import {UIWithPort} from "../UI.m.js";

import startZoom from "/modules/Zoom.m.js";

export
class Radar extends HTMLElement {
	el;
	view;
	background;
	
	scale = 0.01;
	
	constructor() {
		super();
		this.el = svg (
			"svg", "radar",
			"radar-circle",
			Div.attributes({viewBox:"-1 -1 2 2"}),
			svg (	"defs",
				svg (	"clipPath", Div.id("clipCircle"),
					svg (	"circle",
						Div.attributes({cx:"0",cy:"0",r:"1",}),
					),
				),
			),
			svg (	"g",
				Div.attributes({"clip-path":"url(#clipCircle)"}),
				svg (	"rect",
					"radar-background",
					(el)=>{this.background=el},
					Div.attributes({x:"-1",y:"-1",width:"2",height:"2",}),
				),
				svg (	"g",
					"radar-view",
					(el)=>{this.view=el},
					Div.attributes({transform:`scale(${this.scale})`}),
				),
				el => startZoom(el, a=>{
					this.scale = Math.min(0.5,Math.max(0.0001,this.scale*a));
					this.view.setAttribute("transform", `scale(${this.scale})`);
				}),
			),
			svg (	"circle",
				Div.attributes({cx:"0",cy:"0",r:"1",fill:"none",stroke:"black","stroke-width":"0.01",}),
			),
		);
		this.appendChild(this.el);
	}
}

customElements.define('ui-radar', Radar);
