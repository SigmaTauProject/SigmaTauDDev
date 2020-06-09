module ports_.wire_;

import accessors;
import structuredrpc;
import ports_.port_;

import std.traits;
import std.algorithm;
import std.range;
import std.typecons;

enum WirePortType {
	wireIn	= 0x1	,
	wireOut	= 0x2	,
	wire	= wireIn | wireOut	,
}

template WirePort(WirePortType wirePortType, T) {
	alias TRef = T*;
	static if (is(T == class) || isPointer!T) {
		alias TStore = T;
		bool isNull(TStore store) {
			return store is null;
		}
		void nullify(ref TStore store) {
			store = null;
		}
		TRef refify(ref TStore store) {
			return &store;
		}
		T valueify(TStore store) {
			return store;
		}
		T valueify(TRef store) {
			return *store;
		}
	}
	else {
		alias TStore = Nullable!T;
		TRef refify(ref TStore store) {
			return &store.get();
		}
		T valueify(TStore store) {
			return store.get;
		}
		T valueify(TRef store) {
			return *store;
		}
	}
	class WirePort(bool isMaster) : Port!isMaster {
		
		//---Constructors
		public {
			static if (!isMaster)
			this() {
				this_!(typeof(this));
			}
			static if (isMaster)
			this(T v) {
				this_!(typeof(this));
				data = v;
			}
		}
		
		//---Private Members
		private {
			TStore	data		;// null when not listening or listening is waiting for starting value
			invariant {static if (!isMaster) assert(!(data.isNull));}
			
			static if (!isMaster)	void delegate(TRef*)[]	listenWaiters	= []	;
			static if (!isMaster)	void delegate(T)[]	getWaiters	= []	;
			
			static if (!isMaster)	uint	listenRequests	= 0	;
			static if (true)	Client[]	clientListeners	= []	;
			static if (true)	void delegate(T)[]	selfListeners	= []	;
			invariant {static if (!isMaster) assert(listenRequest >= clientListeners.length + selfListeners.length);}
			
			static if (!isMaster)	bool	listening	= false	;
			static if (!isMaster)	bool	getting	= false	;// whether a get was requested from the server, and is still waiting
			invariant {static if (!isMaster) if (!listening) assert(listenWaiters == []);}
		}
		
		
		//---Messages
		//-Get
		private
		void getCore(void delegate(T) callback) {
			static if (isMaster) {
				callback(data.valueify);
			}
			else if (!(data.isNull))
				callback(data.valueify);
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
		
		static if (wirePortType & WirePortType.wireIn || isMaster)
		public
		void get(void delegate(T) callback){
			getCore(callback);
		}
		
		//-Listen & Unlisten
		private
		void listenCore(void delegate(TRef) callback, bool onlyCallback=true) {
			static if (!isMaster)
				listenRequests++;
			static if (isMaster) {
				callback(data.refify);
			}
			else if (!(data.isNull))
				callback(data.refify);
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
			listenCore(v=>set_send!(Trgt.client)([connection], v.valueify), false);
		}
		@RPC(2)
		void unlisten(Src src:Src.client)(ConnectionParam!src connection) {
			clientListeners = clientListeners.remove(clientListeners.countUntil(connection));
			unlistenCore;
		}
		
		//-Direct self listen (hold the value, which changes)
		static if (!isMaster) {
			void listenPull(void delegate(TRef) callback) {
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
		static if (wirePortType & WirePortType.wireIn || isMaster) {
			void listen(void delegate(T) callback) {
				selfListeners ~= callback;
				listenCore(v=>callback(v.valueify), false);
			}
			void unlisten(void delegate(T) callback) {
				selfListeners = selfListeners.remove(selfListeners.countUntil(callback));
				unlistenCore;
			}
		}
		
		
		//-Set
		@RPC(3)
		void set(Src src)(T v) if (wirePortType & WirePortType.wireOut || isMaster || src == Src.server) {
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
						listenWaiters.each!(c=>c(data.refify));
						listenWaiters = [];
					}
				}
				else assert(listenWaiters == []);
			}
		}
		public mixin(defaultSrcMixin("set","Src.self"));
		
		mixin PortMixin_WithRPC PortMixin;
	}
}

////auto uniqueAppend(T)(T[] array, T v) {
////	if (!array.canFind(v))
////		return array ~ v;
////	else
////		return array;
////}

 
