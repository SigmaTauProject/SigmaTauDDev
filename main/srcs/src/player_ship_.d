module player_ship_;

import core.thread.fiber;

////class Fib(alias fun, Arg=typeof(null), Ret=typeof(null)) : Fiber {
////	this(Parameters!fun farg) {
////		super(&run);
////		super.call;
////	}
////	
////	union {
////		Parameters!fun farg;
////		
////		static if (!is(Arg == typeof(null))
////		Arg arg;
////	}
////	static if (!is(Ret == typeof(null))
////	Ret ret;
////	
////	void run() {
////		ret = fun(farg);
////	}
////	static if (is(Arg == typeof(null))
////	override auto call() {
////		super.call;
////		static if (!is(Ret == typeof(null))
////			return ret;
////	}
////	else
////	override auto call(Arg arg) {
////		this.arg = arg;
////		super.call;
////		static if (!is(Ret == typeof(null))
////			return ret;
////	}
////	
////	static if (is(Ret == typeof(null))
////	override auto yield() {
////		Fiber.yield;
////		static if (!is(Arg == typeof(null))
////			return arg;
////	}
////	else
////	override auto yield(Ret ret) {
////		this.ret = ret;
////		Fiber.yield;
////		static if (!is(Arg == typeof(null))
////			return arg;
////	}
////}

import world_;
import math.linear.vector;
import math.linear.point;

import ship_controller_;

import ship_.ship_;
import ship_.net_.ports_.bridge_;
import networking_.terminal_networking_;

class PlayerShip : ShipController {
	ushort port;
	World world;
	
	TerminalServer terminalServer;
	Entity entity;
	Ship ship;
	NetBridge netBridge;
	
	this (ushort port, World world) {
		this.port = port;
		this.world = world;
		
		terminalServer = new TerminalServer(port);
		entity = new Entity(fineShipObject,pvec(48f,0f).fromRelT!WorldPosT,vec(0,0), 16384*0);
		ship = new Ship(world, entity);
		netBridge = new NetBridge(ship.bridge);
		
		netBridge.updateSend;
	}
	
	override void update() {
		terminalServer.update;
		
		auto newClients = terminalServer.getNewTerminals;
		if (newClients.length)
			netBridge.newClients(newClients);
		
		netBridge.update;
		
		ship.update	;
		
		netBridge.updateSend;
	}
}
