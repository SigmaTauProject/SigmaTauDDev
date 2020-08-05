

export
function listenableMixin(Cls, doListen, doPullListen, onListen, onUnlisten, rpcID) {
	Object.defineProperty(Cls.prototype, "listen", {value:
		function(callback) {
			if (this.listenWaiters == undefined) {
				this.listenWaiters = [];
				this.listeners = [];
			}
			this.listenWaiters.push(callback);
			this[onListen]();
			return ()=>this.unlisten(callback);
		}
	});
	Object.defineProperty(Cls.prototype, "pullListen", {value:
		function(callback) {
			if (this.pullListenWaiters == undefined) {
				this.pullListenWaiters = [];
			}
			this.pullListenWaiters.push(callback);
			this[onListen]();
			return ()=>this.unlisten();
		}
	});
	Object.defineProperty(Cls.prototype, "unlisten", {value:
		function(callback) {
			let index;
			if ((index = this.listeners.indexOf(callback)) != -1)
				this.listeners.splice(index, 1);
			else if ((index = this.listenWaiters.indexOf(callback)) != -1)
				this.listenWaiters.splice(index, 1);
			this[onUnlisten]();
		}
	});
	Object.defineProperty(Cls.prototype, "onListenReady", {value:
		function(...args) {
			if (this.listenWaiters && this.listenWaiters.length) {
				this[doListen](this.listenWaiters, ...args);
				this.listeners.push(...this.listenWaiters);
				this.listenWaiters = [];
			}
			if (this.pullListenWaiters && this.pullListenWaiters.length) {
				this[doPullListen](this.pullListenWaiters, ...args);
				this.pullListenWaiters = [];
			}
		}
	});
	Object.defineProperty(Cls.prototype, "listenerCall", {value:
		function(fun, ...args) {
			if (this.listeners && this.listeners.length) {
				this[fun](this.listeners, ...args);
			}
		}
	});
}

