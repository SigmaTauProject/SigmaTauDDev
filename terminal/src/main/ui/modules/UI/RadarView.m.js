import {div, svg, Div} from "/modules/Div.m.js";

export
class RadarView {
	
	constructor(radar, radarPort, {}={}) {
		let view = radar.view;
		let shipEls = [];
		({unlisten:this.destroy} = radarPort.listen(radarData=>{
			radarData.entities.map((entity, i)=>{
				if (i >= shipEls.length) {
					shipEls.push	([ svg("polygon", "entity", Div.attributes({points:"-0.7,0.7 0,-1 0.7,0.7 0,0.25"}))
						, svg("circle", "entity", Div.attributes({r:"1", stroke:"black", "stroke-width":"0.05", fill:"none",}))
						, svg("circle", "entity", Div.attributes({r:"1", stroke:"black", "stroke-width":"0.05", fill:"none",}))
						////, svg("polygon", "entity", Div.attributes({points:"-0.25,0.25 -0.25,-0.25 0.25,-0.25 0.25,0.25"}))
						]);
					////shipEls.push	([ svg("circle", "entity", Div.attributes({r:"1"}))
					////	,  svg("circle", "entity", Div.attributes({r:"1"}))
					////	]);
					view.appendChild(shipEls[i][0]);
					view.appendChild(shipEls[i][1]);
					view.appendChild(shipEls[i][2]);
				}
				shipEls[i][0].setAttribute("transform",`translate(${entity.pos[0]}, ${-entity.pos[1]}) rotate(${entity.ori * (360 / 65536)})`);
				shipEls[i][1].setAttribute("transform",`translate(${entity.pos[0]}, ${-entity.pos[1]})`);
				shipEls[i][2].setAttribute("transform",`translate(${(entity.pos[0]+entity.vel[0])}, ${-(entity.pos[1]+entity.vel[1])})`);
			});
			if (shipEls.length > radarData.entities.length)
				console.warn("Unimlemented, reduction in radar entity count");
		}));
	}
	
	update() {}
	
	destory;
}

