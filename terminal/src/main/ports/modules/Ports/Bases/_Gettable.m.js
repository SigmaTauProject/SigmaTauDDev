
export
function gettableMixin(Cls, doGet, onGet) {
	Object.defineProperty(Cls.prototype, "get", {value:
		function(callback) {
			if (this.getWaiters == undefined)
				this.getWaiters = [];
			this.getWaiters.push(callback);
			this[onGet]();
		}
	});
	Object.defineProperty(Cls.prototype, "onGetReady", {value:
		function(...args) {
			if (this.getWaiters && this.getWaiters.length) {
				this[doGet](this.getWaiters, ...args);
				this.getWaiters = [];
			}
		}
	});
}

////mixin template Gettable(string doGetName, alias onGet) {
////	import std.conv : to;
////	static foreach(i, fun; __traits(getOverloads, typeof(this), doGetName)) {
////		mixin("Parameters!fun[0] getWaiters"~i.to!string~" = [];");
////		static if ([getUDAs!(fun, RPCGetID), RPCGetID(-1)][0].rpcID < 0 || [getUDAs!(fun, RPCGetID), RPCGetID(-1)][0].rpcID > ubyte.max)
////		@RPC(rpcID)
////		void get(ForeachType!(Parameters!fun[0]) con) {
////			onGet;
////			mixin("getWaiters"~i.to!string~" ~= con;");
////		}
////	}
////	void onGetReady() {
////		static foreach(i, fun; __traits(getOverloads, typeof(this), doGetName)) {
////			mixin(doGetName~"(getWaiters"~i.to!string~");");
////			mixin("getWaiters"~i.to!string~".length=0;");
////			mixin("getWaiters"~i.to!string~".assumeSafeAppend;");// Optimization, verifying that getWaiters in not being used anywhere else.
////		}
////	}
////}

