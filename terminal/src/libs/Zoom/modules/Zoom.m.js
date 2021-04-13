
import startWheelZoom from "/modules/Zoom/Wheel.m.js";
import startPinchZoom from "/modules/Zoom/Pinch.m.js";

export function startZoom(el=document, scrollCallback) {
	startWheelZoom(el, a=>{
		a /= 5;
		if (a < 0)
			a = 1/(-a + 1);
		else
			a = a + 1;
		scrollCallback(a);
	})
	startPinchZoom(el, a=>{
		if (a > 1)
			scrollCallback(a*1.1);
		else
			scrollCallback(a*(1/1.1));
	});
}
export default startZoom;
