 module ports_.bases_._gettable_;

struct RPCGetID {
	int rpcID;
}
mixin template LoneGettable(alias doGet, alias onGet, int rpcID) {
	alias Con = ForeachType!(Parameters!doGet[0]);
	Con[] getWaiters;
	
	static if (rpcID < 0 || rpcID > ubyte.max)
		void get(Con con) {
			getWaiters ~= con;
			onGet;
		}
	else
		@RPC!SrcClient(cast(ubyte) rpcID)
		void get(Con con) {
			getWaiters ~= con;
			onGet;
		}
	void onGetReady(Parameters!doGet[1..$] args) {
		doGet(getWaiters, args);
		getWaiters.length = 0;
		getWaiters.assumeSafeAppend;// Optimization, verifying that getWaiters in not being used anywhere else.
	}
}
mixin template Gettable(string doGetName, alias onGet) {
	import std.conv : to;
	static foreach(i, doGet; __traits(getOverloads, typeof(this), doGetName)) {
		mixin("mixin LoneGettable!(doGet, onGet, [getUDAs!(doGet, RPCGetID), RPCGetID(-1)][0].rpcID) mixin_"~i.to!string~"_;");
		mixin("alias get = mixin_"~i.to!string~"_.get;");
	}
	void onGetReady(Parameters!(mixin(doGetName))[1..$] args) {
		static foreach(i, fun; __traits(getOverloads, typeof(this), doGetName)) {
			mixin("mixin_"~i.to!string~"_.onGetReady(args);");
		}
	}
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

