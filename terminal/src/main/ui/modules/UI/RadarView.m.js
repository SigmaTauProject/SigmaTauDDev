import {div, svg, Div} from "/modules/Div.m.js";

export
class RadarView {
	
	constructor(radar, radarPort, {}={}) {
		let view = radar.view;
		let shipEls = [];
		({unlisten:this.destroy} = radarPort.listen((newEntities, removedEntities, entities)=>{
			newEntities.map((entity, i)=>{
				shipEls.push	([ svg("polygon", "entity", Div.attributes({points:entity.shape.map(p=>p[0]+","+p[1]).join(" ")}))
					, svg("circle", "entity", Div.attributes({r:entity.radius, stroke:"black", "stroke-width":"0.05", fill:"none",}))
					, svg("circle", "entity", Div.attributes({r:entity.radius, stroke:"black", "stroke-width":"0.05", fill:"none",}))
					////, svg("polygon", "entity", Div.attributes({points:"-0.25,0.25 -0.25,-0.25 0.25,-0.25 0.25,0.25"}))
					]);
				////shipEls.push	([ svg("circle", "entity", Div.attributes({r:"1"}))
				////	,  svg("circle", "entity", Div.attributes({r:"1"}))
				////	]);
				view.appendChild(shipEls[shipEls.length-1][0]);
				view.appendChild(shipEls[shipEls.length-1][1]);
				view.appendChild(shipEls[shipEls.length-1][2]);
			});
			removedEntities.map(e=>{
				view.removeChild(shipEls[e][0]);
				view.removeChild(shipEls[e][1]);
				view.removeChild(shipEls[e][2]);
				shipEls.splice(e,1);
			});
			entities.map((entity, i)=>{
				shipEls[i][0].setAttribute("transform",`translate(${entity.pos[1]}, ${-entity.pos[0]}) rotate(${entity.ori * (360 / 65536)})`);
				shipEls[i][1].setAttribute("transform",`translate(${entity.pos[1]}, ${-entity.pos[0]})`);
				shipEls[i][2].setAttribute("transform",`translate(${(entity.pos[1]+entity.vel[1])}, ${-(entity.pos[0]+entity.vel[0])})`);
			});
		}));
	}
	
	update() {}
	
	destory;
}

