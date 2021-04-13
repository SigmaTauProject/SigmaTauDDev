 

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
					if ((max>snap && valuePtr.payload>snap) || (max<snap && valuePtr.payload<snap))
						wirePort.set(snap);
					e.preventDefault();
				}
				else if (e.code == negKey) {
					negKeyDown = false;
					if ((min>snap && valuePtr.payload>snap) || (min<snap && valuePtr.payload<snap))
						wirePort.set(snap);
					e.preventDefault();
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

export
class PingKey {
	destory() {}
	
	constructor(pingPort, key, {}={}) {
		window.addEventListener("keydown",(e)=>{
			if (e.code == key) {
				pingPort.ping();
				e.preventDefault();
			}
		});
	}
}




