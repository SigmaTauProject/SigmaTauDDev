module ports_.ping_;

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

class PingOutPort(bool isMaster) : Port!isMaster {
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
		void doSend(void delegate()[] connections) {
			connections.each!(con=>con());
		}
		
		mixin LoneListenable!(doListen, onListen, onUnlisten, 1);
		void doListen(void delegate()[] _) {
		}
		void onListen() {
			onListenReady;
		}
		void onUnlisten() {
		}
	}
	
	//-Setting
	@RPC!SrcClient(3)
	void ping(Src)() if (is(Src==SrcClient) || (isMaster && is(Src==SrcSelf))) {
		static if (isMaster)
			listenerCall!"doSend";
		else
			ping_send!TrgtServer;
	}
	static if (isMaster)
	void ping() {
		ping!SrcSelf;
	}
	
	mixin PortMixin_WithRPC;
}
