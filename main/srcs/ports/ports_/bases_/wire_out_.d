module ports_.bases_.wire_out_;

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

template WireOutPortBase(T) {
	mixin Accessable!T;
	class WireOutPortBase(bool isMaster) : Port!isMaster {
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
			static if (isMaster) TStore	data		;// null when not listening or listening is waiting for starting value
			invariant {static if (isMaster) assert(!data.isNull);}
		}
		
		///---Messages
		//-Getting & Listening
		
		static if (isMaster) {
			@RPCGetID(0)
			@RPCListenID(1)
			void doSend(void delegate(T)[] connections) {
				connections.each!(con=>con(data.valueify));
			}
			
			mixin Gettable!("doSend", onGet) GettableMixin;
			void onGet() {
				onGetReady;
			}
			T get() {
				return data.valueify;
			}
			alias get = GettableMixin.get;
			
			mixin Listenable!("doSend", onListen, onUnlisten);
			void onListen() {
				onListenReady;
			}
			void onUnlisten() {
			}
		}
		
		//-Setting
		@RPC!SrcClient(3)
		void set(Src)(T v) if (!is(Src == SrcServer)) {
			static if (isMaster) {
				data = v;
				listenerCall!"doSend";
			}
			static if (!isMaster)
				set_send!TrgtServer(v);
		}
		static if (isMaster)
		void set(T v) {
			set!SrcSelf(v);
		}
		
		mixin PortMixin_WithRPC;
	}
}
