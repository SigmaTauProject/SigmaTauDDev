import {div, svg, Div} from "/modules/Div.m.js";

export
class Radar {
	el;
	destroy;
	
	constructor(radarPort, {}={}) {
		let view;
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
					Div.attributes({x:"-1",y:"-1",width:"2",height:"2",}),
				),
				svg (	"g",
					"radar-view",
					(el)=>{view=el},
					Div.attributes({transform:"scale(0.05)"}),
				),
			),
			svg (	"circle",
				Div.attributes({cx:"0",cy:"0",r:"1",fill:"none",stroke:"black","stroke-width":"0.01",}),
			),
		);
		let shipEls = [];
		({unlisten:this.destroy} = radarPort.listen(radarData=>{
			radarData.entities.map((entity, i)=>{
				if (i >= shipEls.length) {
					shipEls.push(svg("polygon", "entity", Div.attributes({points:"-0.5,0.5 0,-0.5 0.5,0.5 0,0.25"})));
					view.appendChild(shipEls[i]);
				}
				shipEls[i].setAttribute("transform",`translate(${entity[0]/500}, ${-entity[1]/500})`);
			});
			if (shipEls.length > radarData.entities.length)
				console.warn("Unimlemented, reduction in radar entity count");
		}));
	}
}

