
export default function startPinchZoom(el=document, scrollCallback) {
	var lastPinchDistance = null;
	el.addEventListener("touchstart",(e)=>{
		if (e.touches.length>1) {
			e.preventDefault();
			e.stopPropagation();
			if (e.touches.length==2) {
				lastPinchDistance = pinchDistance(e);
			}
			else {
				lastPinchDistance = null;
			}
		}
	},{passive: false});
	el.addEventListener("touchmove",(e)=>{
		if (e.touches.length>1) {
			e.preventDefault();
			e.stopPropagation();
			if (lastPinchDistance!=null) {
				let newPinchDistance = pinchDistance(e);
				let amount = newPinchDistance/lastPinchDistance;
				lastPinchDistance = newPinchDistance;
				
				scrollCallback(amount);
			}
		}
	},{passive: false});
	el.addEventListener("touchend",(e)=>{
		if (e.touches.length>1) {
			e.preventDefault();
			e.stopPropagation();
		}
		if (lastPinchDistance!=null) {
			lastPinchDistance = null;
		}
	},{passive: false});
}

function pinchDistance(e) {
	return Math.hypot(e.touches[1].clientX-e.touches[0].clientX, e.touches[1].clientY-e.touches[0].clientY);
}
function pinchPosition(e) {
	return [(e.touches[1].clientX+e.touches[0].clientX)/2, (e.touches[1].clientY+e.touches[0].clientY)/2];
}


