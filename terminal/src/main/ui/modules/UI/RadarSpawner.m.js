import {div, svg, Div} from "/modules/Div.m.js";

export
class RadarSpawner {
	
	constructor(radar, spawnerPort, {}={}) {
		radar.background.addEventListener("click",ev=>spawnerPort.set(viewPoint(radar.el,radar.background,ev.clientX,ev.clientY)));
	}
	
	update() {}
	
	destory() {}
}

// translate page to SVG co-ordinate
function viewPoint(svg, element, x, y) {
  var pt = svg.createSVGPoint();

  pt.x = x;
  pt.y = y;
  pt = pt.matrixTransform(element.getScreenCTM().inverse());

  return [pt.x*20*1500, -pt.y*20*1500];
}
