import cst_;
import std.stdio;
import std.string;
import std.exception;
import std.algorithm;

import world_.world_;
import world_.entity_;
import world_.entity_object_;
import math.linear.vector;
import math.linear.point;

import ship_.ship_;
import networking_.terminal_networking_;

import core.time;
import std.datetime;
import core.thread;

void main() {
	World world = new World;
	auto terminalServer = new TerminalServer();
	
	{
		auto entity = new Entity(planetObject, pvec(0L,0),vec(0,0), 16384*0);
		world.addEntity(entity);
		world.physicsWorld.gravityWells ~= entity;
	}
	world.addEntity(new Entity(stationObject, pvec(0L,64.fromFloat!long),vec(8.fromFloat!int,0), 16384*0));
	
	auto ship = new Ship(world);
	
	while (true) {
		auto loopStartTime = MonoTime.currTime;
		terminalServer.update;
		world.update;
		ship.update(terminalServer.getNewTerminals);
		
		Thread.sleep(max(0.msecs, 100.msecs - (MonoTime.currTime - loopStartTime)));
		////if (readln()=="q")
		////	break;
	}
}

