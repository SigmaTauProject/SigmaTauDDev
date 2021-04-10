
export default function startWheelZoom(el=document, scrollCallback) {
	el.addEventListener("wheel",(e)=>{
		let amount;
		if (e.deltaMode==0) {
			amount = -e.deltaY / 48;
			if (amount%1 != 0) {
				console.warn("Unexpected wheel delta value. Got "+e.deltaY+", expected multiple of 53.");
			}
		}
		else if (e.deltaMode==1) {
			amount = -e.deltaY / 3;
			if (amount%1 != 0) {
				console.warn("Unexpected wheel delta value. Got "+e.deltaY+", expected multiple of 3.");
			}
		}
		else {
			console.warn('Got wheel `detaMode` of "page", using to fallback handling.');
			if (e.deltaY<0)
				amount = 1;
			else if (e.deltaY>0)
				amount = -1;
			else
				amount = 0;
		}
		e.preventDefault();
		e.stopPropagation();
		scrollCallback(amount);
	},{passive: false});
}


