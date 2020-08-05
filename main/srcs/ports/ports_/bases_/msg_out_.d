module ports_.bases_.msg_out_;

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

template MsgOutPortBase(T) {
	class MsgOutPortBase(bool isMaster) : Port!isMaster {
		//---Constructors
		public {
			this() {
				this_!(typeof(this));
			}
		}
		
		//---Private Members
		private {
		}
		
		///---Messages
		//-Getting & Listening
		
		static if (isMaster) {
			void doSend(void delegate(T)[] connections, T value) {
				connections.each!(con=>con(value));
			}
			
			mixin LoneListenable!(doListen, onListen, onUnlisten, 1);
			void doListen(void delegate(T)[] _) {
			}
			void onListen() {
				onListenReady;
			}
			void onUnlisten() {
			}
		}
		
		//-Setting
		@RPC!SrcClient(3)
		void send(Src)(T v) {
			static if (isMaster) {
				listenerCall!"doSend"(v);
			}
		}
		static if (isMaster)
		void send(T v) {
			send!SrcSelf(v);
		}
		
		mixin PortMixin_WithRPC;
	}
}
