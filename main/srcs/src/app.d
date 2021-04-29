import cst_;
import std.stdio;
import std.string;
import std.exception;
import std.algorithm;

import sigtrace;

import world_.world_;
import world_.entity_;
import world_.entity_object_;
import math.linear.vector;
import math.linear.point;

import player_ship_;
import ai_ship_;

import core.time;
import std.datetime;
import core.thread;

void main() {
	World world = new World;
	
	{
		auto entity = new Entity(planetObject, pvec(0L,0),vec(0,0), 16384*0);
		world.addEntity(entity);
		world.physicsWorld.gravityWells ~= entity;
	}
	world.addEntity(new Entity(stationObject, pvec(0L,128.fromFloat!long),vec((0.5).fromFloat!int,0), 16384*0));
	
	auto ships = [
		new PlayerShip(8080, world)	,
		new AIShip(world)	,
	];
	
	while (true) {
		auto loopStartTime = MonoTime.currTime;
		
		ships.each!(ship=>ship.call);
		
		world.update;
		
		Thread.sleep(max(0.msecs, 100.msecs - (MonoTime.currTime - loopStartTime)));
		////if (readln()=="q")
		////	break;
	}
}

