module ship_.ports_.wire_;

import accessors;
import structuredrpc;
import ship_.ports_.port_;

import std.traits;
import std.algorithm;
import std.range;
import std.typecons;

class WirePort(bool isMaster) : Port!isMaster {
	
	//---Constructors
	public {
		static if (!isMaster)
		this() {
			super(PortType.wire);
		}
		static if (isMaster)
		this(float v) {
			super(PortType.wire);
			data = v;
		}
	}
	
	//---Private Members
	private {
		Nullable!float	data		;// null when not listening or listening is waiting for starting value
		invariant {static if (!isMaster) assert(!(data.isNull));}
		
		static if (!isMaster)	void delegate(float*)[]	listenWaiters	= []	;
		static if (!isMaster)	void delegate(float)[]	getWaiters	= []	;
		
		static if (!isMaster)	uint	listenRequests	= 0	;
		static if (true)	Terminal[]	clientListeners	= []	;
		static if (true)	void delegate(float)[]	selfListeners	= []	;
		invariant {static if (!isMaster) assert(listenRequest >= clientListeners.length + selfListeners.length);}
		
		static if (!isMaster)	bool	listening	= false	;
		static if (!isMaster)	bool	getting	= false	;// whether a get was requested from the server, and is still waiting
		invariant {static if (!isMaster) if (!listening) assert(listenWaiters == []);}
	}
	
	
	//---Messages
	//-Get
	private
	void getCore(void delegate(float) callback) {
		static if (isMaster) {
			callback(data.get);
		}
		else if (!(data.isNull))
			callback(data.get);
		else {
			if (!(listening || getting)) {
				get_send!(Trgt.server);
				getting = true;
			}
			getWaiters ~= callback;
		}
	}
	
	@RPC(0) private
	void get(Src src:Src.client)(ConnectionParam!src connection) {
		getCore(v=>set_send!(Trgt.client)([connection], v));
	}
	
	public
	void get(void delegate(float) callback){
		getCore(callback);
	}
	
	//-Listen & Unlisten
	private
	void listenCore(void delegate(float*) callback, bool onlyCallback=true) {
		static if (!isMaster)
			listenRequests++;
		static if (isMaster) {
			callback(&data.get());
		}
		else if (!(data.isNull))
			callback(&data.get());
		else {
			if (!(listening)) {
				listen_send!(Trgt.server);
				listening = true;
			}
			// else: listening, but data not recived yet to start
			if (onlyCallback)
				listenWaiters ~= callback;
			// else listen callback will be handled via normal method when value is recieved from server
		}
	}
	void listenCore() {
		listenCore((d){}, false);
	}
	private
	void unlistenCore() {
		static if (!isMaster) {
			assert(listenRequest > 0);
			listenRequests--;
			if (!listenRequests) {
				unlisten_send!(Trgt.server);
				listening = false;
				data.nullify;
				listenWaiters = [];
				assert(!clientListeners.length);
				assert(!selfListeners.length);
			}
		}
	}
	
	@RPC(1) private
	void listen(Src src:Src.client)(ConnectionParam!src connection) {
		assert(!clientListeners.canFind(connection));
		clientListeners ~= connection;
		listenCore(v=>set_send!(Trgt.client)([connection], *v), false);
	}
	@RPC(2)
	void unlisten(Src src:Src.client)(ConnectionParam!src connection) {
		clientListeners = clientListeners.remove(clientListeners.countUntil(connection));
		unlistenCore;
	}
	
	//-Direct self listen (hold the value, which changes)
	static if (!isMaster) {
		void listen(void delegate(float*) callback) {
			listenCore(callback);
		}
		void listen() {
			listenCore();
		}
		void unlisten() {
			unlistenCore;
		}
	}
	
	//-Change Listen (get callback on every change)
	void listen(void delegate(float) callback) {
		selfListeners ~= callback;
		listenCore(v=>callback(*v), false);
	}
	void unlisten(void delegate(float) callback) {
		selfListeners = selfListeners.remove(selfListeners.countUntil(callback));
		unlistenCore;
	}
	
	
	//-Set
	@RPC(3)
	void set(Src src)(float v) {
		selfListeners.each!(l=>l(v));
		static if (isMaster) {
			data = v;
		}
		else {
			static if (src != Src.server) 
				set_send!(Trgt.server)(v);
			
			static if (src == Src.server) {
				static if (getting) {
					assert(data.isNull);
					getWaiters.each!(c=>c(v));
					getWaiters = [];
					getting = false;
				}
				else assert(getWaiters == []);
			}
			
			if (listening) {
				if (!(data.isNull)) {
					data = v;
					assert(listenWaiters == []);
				}
				else {
					data = v;
					listenWaiters.each!(c=>c(&data.get()));
					listenWaiters = [];
				}
			}
			else assert(listenWaiters == []);
		}
	}
	public mixin(defaultSrcMixin("set","Src.self"));
	
	mixin PortMixin_WithRPC PortMixin;
}


////auto uniqueAppend(T)(T[] array, T v) {
////	if (!array.canFind(v))
////		return array ~ v;
////	else
////		return array;
////}

 
