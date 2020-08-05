module ports_.bases_.wire_in_;

import accessors;
import structuredrpc;
import ports_.port_;

import std.traits;
import std.algorithm;
import std.range;
import std.typecons;

import ports_.bases_._accessable_;
import ports_.bases_._gettable_;
import ports_.bases_._listenable_;

template WireInPortBase(T) {
	mixin Accessable!T;
	class WireInPortBase(bool isMaster) : Port!isMaster {
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
			invariant {static if (isMaster) assert(!data.isNull);}
			
			static if (!isMaster)	bool	dataComing	= false	;
			static if (!isMaster)	size_t	listeners	= 0	;
		}
		
		///---Messages
		//-Getting
		
		@RPCGetID(0)
		@RPCListenID(1)
		void doSend(Client[] connections) {
			set_send!TrgtClient(connections, data.valueify);
		}
		void doSend(void delegate(T)[] connections) {
			connections.each!(con=>con(data.valueify));
		}
		
		static if (isMaster) {
			mixin Gettable!("doSend", onGet) GettableMixin;
			void onGet() {
				onGetReady;
			}
			T get() {
				return data.valueify;
			}
			alias get = GettableMixin.get;
		}
		else {
			mixin Gettable!("doSend", onGet);
			void onGet() {
				if (!data.isNull)
					onGetReady;
				else if (!dataComing) {
					get_send!TrgtServer;
					dataComing = true;
				}
			}
		}
		
		//-Listening
		static if (isMaster) {
			mixin Listenable!("doSend", onListen, onUnlisten);
			void onListen() {
				onListenReady;
			}
			void onUnlisten() {
			}
		}
		else {
			mixin Listenable!("doSend", onListen, onUnlisten);
			void onListen() {
				if (!data.isNull)
					onListenReady;
				else if (!listeners)  {
					listen_send!TrgtServer;
					dataComing = true;
				}
				listeners++;
			}
			void onUnlisten() {
				listeners--;
				if (!listeners) {
					unlisten_send!TrgtServer;
					data.nullify;
				}
			}
		}
		
		//-Setting
		@RPC!SrcServer(3)
		void set(Src)(T v) {
			data = v;
			static if(!isMaster)
				dataComing = false;
			static if (!isMaster)
				onGetReady;
			listenerCall!"doSend";
			static if (!isMaster)
				onListenReady;
			static if (!isMaster) if (!listeners)
				data.nullify;
		}
		static if (isMaster)
		void set(T v) {
			set!SrcSelf(v);
		}
		
		mixin PortMixin_WithRPC;
	}
}
