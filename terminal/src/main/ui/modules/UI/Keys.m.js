 

export
class WireKeys {
	destory;
	
	constructor(wirePort, key, {max=1,min=-1,snap=0, step=0.1, negKey=null}={}) {
		let valuePtr;
		var keyDown = false;
		var negKeyDown = false;
		wirePort.pullListen(vp=> {
			valuePtr = vp;
			window.addEventListener("keydown",(e)=>{
				if (e.code == key) {
					keyDown = true;
				}
				else if (e.code == negKey) {
					negKeyDown = true;
				}
			});
			window.addEventListener("keyup",(e)=>{
				if (e.code == key) {
					keyDown = false;
					if (snap != null && ((max>0 && valuePtr.payload>0) || (max<0 && valuePtr.payload<0)))
						wirePort.set(snap);
				}
				else if (e.code == negKey) {
					negKeyDown = false;
					if (snap != null && ((min>0 && valuePtr.payload>0) || (min<0 && valuePtr.payload<0)))
						wirePort.set(snap);
				}
			});
		});
		let update = ()=>{
			let mod;
			if (keyDown && negKeyDown)
				wirePort.set(0);
			else if ((mod = max*keyDown + min*negKeyDown) != 0)
				wirePort.set(Math.max(min, Math.min(max,valuePtr.payload + mod * step)));
		};
		setInterval(update, 100);
		this.destroy = ()=>removeInterval(update);
	}
}




