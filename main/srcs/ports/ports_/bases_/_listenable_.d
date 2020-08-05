module ports_.bases_._listenable_;

struct RPCListenID {
	int rpcID;
}
mixin template LoneListenable(alias doListen, alias onListen, alias onUnlisten, int rpcID) {
	alias Con = ForeachType!(Parameters!doListen[0]);
	Con[] listenWaiters;
	Con[] listeners;
	
	static if (rpcID < 0 || rpcID > ubyte.max) {
		void listen(Con con) {
			listenWaiters ~= con;
			onListen;
		}
		void unlisten(Con con) {
			if (auto index = listeners.countUntil(con) +1)
				listeners = listeners.remove(index -1);
			else if (auto index = listenWaiters.countUntil(con) +1)
				listenWaiters = listenWaiters.remove(index -1);
			onUnlisten;
		}
	}
	else {
		@RPC!SrcClient(cast(ubyte) rpcID)
		void listen(Con con) {
			listenWaiters ~= con;
			onListen;
		}
		@RPC!SrcClient(cast(ubyte) rpcID+1)
		void unlisten(Con con) {
			if (auto index = listeners.countUntil(con) +1)
				listeners = listeners.remove(index -1);
			else if (auto index = listenWaiters.countUntil(con) +1)
				listenWaiters = listenWaiters.remove(index -1);
			onUnlisten;
		}
	}
	void onListenReady(Parameters!doListen[1..$] args) {
		doListen(listenWaiters, args);
		listeners ~= listenWaiters;
		listenWaiters.length = 0;
		listenWaiters.assumeSafeAppend;// Optimization, verifying that listenWaiters in not being used anywhere else.
	}
	void listenerCall(string fun)(Parameters!(mixin(fun))[1..$] args) {
		mixin(fun)(listeners, args);
	}
}
mixin template Listenable(string doListenName, alias onListen, alias onUnlisten) {
	import std.conv : to;
	static foreach(i, doListen; __traits(getOverloads, typeof(this), doListenName)) {
		mixin("mixin LoneListenable!(doListen, onListen, onUnlisten, [getUDAs!(doListen, RPCListenID), RPCListenID(-1)][0].rpcID) mixin_"~i.to!string~"_;");
		mixin("alias listen = mixin_"~i.to!string~"_.listen;");
		mixin("alias unlisten = mixin_"~i.to!string~"_.unlisten;");
	}
	void onListenReady(Parameters!(mixin(doListenName))[1..$] args) {
		static foreach(i, _; __traits(getOverloads, typeof(this), doListenName)) {
			mixin("mixin_"~i.to!string~"_.onListenReady(args);");
		}
	}
	void listenerCall(string fun)(Parameters!(mixin(fun))[1..$] args) {
		static foreach(i, _; __traits(getOverloads, typeof(this), doListenName)) {
			mixin("mixin_"~i.to!string~"_.listenerCall!fun(args);");
		}
	}
}


////mixin template Listenable(string doListen, alias doUnlisten, alias onListen, ubyte rpcID=-1) {
////	size_t numListeners = 0;
////	static foreach(i, fun; __traits(getOverloads, typeof(this), doListen)) {
////		mixin("Parameters!fun[0][] listenWaiters"~i~" = [];");
////		mixin("Parameters!fun[0][] listeners"~i~" = [];");
////		@RPC(rpcID)
////		void listen(ForeachType!(Parameters!fun)[0] con) {
////			numListeners++;
////			mixin("listenWaiters"~i~" ~= con;");
////			onListen;
////		}
////		@RPC(rpcID+1)
////		void unlisten(ForeachType!(Parameters!fun)[0] con) {
////			if (index = mixin("listeners"~i~".countUntil(con)"))
////				mixin("listeners"~i~" = listeners"~i~".remove(index);");
////			else if (index = mixin("listenWaiters"~i~".countUntil(con)"))
////				mixin("listenWaiters"~i~" = listenWaiters"~i~".remove(index);");
////			numListeners--;
////			onUnlisten;
////		}
////		void onListenReady() {
////			mixin(doListen~"(listenWaiters"~i~");");
////			mixin("listeners"~i~" ~= listenWaiters"~i~";");
////			mixin("listenWaiters"~i~".length = ;");
////			mixin("listenWaiters"~i~".assumeSafeAppen;");// Optimization, verifying that listenWaiters in not being used anywhere else.
////		}
////		void listenerCall(string fun)(Parameters!(mixin(fun))[1..$] args) {
////			fun(mixin("listeners"~i), args);
////		}
////	}
////}

