import {div, svg, Div} from "/modules/Div.m.js";

export
class RadarView {
	
	constructor(radar, radarPort, {}={}) {
		let view = radar.view;
		let shipEls = [];
		({unlisten:this.destroy} = radarPort.listen(radarData=>{
			radarData.entities.map((entity, i)=>{
				if (i >= shipEls.length) {
					shipEls.push(svg("polygon", "entity", Div.attributes({points:"-0.5,0.5 0,-0.5 0.5,0.5 0,0.25"})));
					view.appendChild(shipEls[i]);
				}
				shipEls[i].setAttribute("transform",`translate(${entity[0]/1500}, ${-entity[1]/1500})`);
			});
			if (shipEls.length > radarData.entities.length)
				console.warn("Unimlemented, reduction in radar entity count");
		}));
	}
	
	update() {}
	
	destory;
}

