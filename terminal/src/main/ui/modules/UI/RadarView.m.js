import {div, svg, Div} from "/modules/Div.m.js";
import {Port, PortType} from "/modules/Ports/Port.m.js";
import {UIWithPort} from "../UI.m.js";

export
class RadarView  extends UIWithPort {
	view = null;
	shipEls = [];
	
	static portType = PortType.radar;
	
	portListenCallback(newEntities, removedEntities, entities) {
		newEntities.map((entity, i)=>{
			this.shipEls.push	([ svg("polygon", "entity", Div.attributes({points:entity.shape.map(p=>p[0]+","+p[1]).join(" ")}))
				, svg("circle", "entity", Div.attributes({r:entity.radius, stroke:"black", "stroke-width":"0.05", fill:"none",}))
				, svg("circle", "entity", Div.attributes({r:entity.radius, stroke:"black", "stroke-width":"0.05", fill:"none",}))
				////, svg("polygon", "entity", Div.attributes({points:"-0.25,0.25 -0.25,-0.25 0.25,-0.25 0.25,0.25"}))
				]);
			////shipEls.push	([ svg("circle", "entity", Div.attributes({r:"1"}))
			////	,  svg("circle", "entity", Div.attributes({r:"1"}))
			////	]);
			if (this.view != null) {
				this.view.appendChild(this.shipEls.last[0]);
				this.view.appendChild(this.shipEls.last[1]);
				this.view.appendChild(this.shipEls.last[2]);
			}
		});
		removedEntities.map(e=>{
			this.view.removeChild(this.shipEls[e][0]);
			this.view.removeChild(this.shipEls[e][1]);
			this.view.removeChild(this.shipEls[e][2]);
			this.shipEls.splice(e,1);
		});
		entities.map((entity, i)=>{
			this.shipEls[i][0].setAttribute("transform",`translate(${entity.pos[1]}, ${-entity.pos[0]}) rotate(${entity.ori * (360 / 65536)})`);
			this.shipEls[i][1].setAttribute("transform",`translate(${entity.pos[1]}, ${-entity.pos[0]})`);
			this.shipEls[i][2].setAttribute("transform",`translate(${(entity.pos[1]+entity.vel[1])}, ${-(entity.pos[0]+entity.vel[0])})`);
		});
	}
	
	connectedCallback(...args) {
		super.connectedCallback(...args);
		this.adaptedCallback();
	}
	adaptedCallback(...args) {
		this.view = this.querySelectorParent("ui-radar")?.view || null;
		if (this.view != null) for (let shipEl of this.shipEls) {
			this.view.appendChild(shipEl[0]);
			this.view.appendChild(shipEl[1]);
			this.view.appendChild(shipEl[2]);
		}
	}
	disconnectedCallback(...args) {
		super.disconnectedCallback(...args);
		if (this.view != null) for (let shipEl of this.shipEls) {
			this.view.removeChild(shipEl[0]);
			this.view.removeChild(shipEl[1]);
			this.view.removeChild(shipEl[2]);
		}
		this.view = null;
	}
}

customElements.define('ui-radar-view', RadarView);
