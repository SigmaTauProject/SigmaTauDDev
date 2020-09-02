import {div, svg, Div} from "/modules/Div.m.js";

export
class RadarSpawner {
	
	constructor(radar, spawnerPort, {}={}) {
		radar.background.addEventListener("click",ev=>spawnerPort.send(viewPoint(radar.el,radar.view,ev.clientX,ev.clientY)));
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

  return [-pt.y, pt.x];
}
