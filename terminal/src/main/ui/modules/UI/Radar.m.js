import {div, svg, Div} from "/modules/Div.m.js";

export
class Radar {
	el;
	view;
	background;
	
	constructor({}={}) {
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
					Div.attributes({transform:"scale(0.01)"}),
				),
			),
			svg (	"circle",
				Div.attributes({cx:"0",cy:"0",r:"1",fill:"none",stroke:"black","stroke-width":"0.01",}),
			),
		);
	}
	
	update() {}
	
	destory() {}
}

