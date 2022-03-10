import cst_;
import std.stdio;
import std.string;
import std.exception;
import std.algorithm;

import sigtrace;

import updaterate_;

import world_.World_;
import world_.Entity_;
import world_.Entity_Object_;
import math.linear.vector;
import math.linear.point;

import debug_rendering_.debug_rendering_;

import player_ship_;
import ai_ship_;

import core.time;
import std.datetime;
import core.thread;

void main() {
	World world = new World;
	DebugRendering debugRendering = new DebugRendering(world);
	{
		auto entity = new Entity(planetObject, pvec(0L,0),vec(0,0), 16384*0);
		world.addEntity(entity);
		world.physicsWorld.gravityWells ~= entity;
	}
	world.addEntity(new Entity(stationObject, pvec(0f,128f).fromRelT!WorldPosT,vec(0.5f,0).fromRelT!WorldVelT, 16384*0));
	
	auto ships = [
		new PlayerShip(8080, world)	,
		new AIShip(world)	,
	];
	
	while (true) {
		auto startTime = MonoTime.currTime;
		
		world.update();
		debugRendering.update();
		ships.each!(ship=>ship.update());
		
		Thread.sleep(max(0.msecs, updaterate - (MonoTime.currTime - startTime)));
		////if (readln()=="q")
		////	break;
	}
}

