import cst_;
import std.stdio;
import std.string;
import std.exception;
import std.algorithm;

import math.linear.vector;
import math.linear.point;
import math.geometry.line;

import GameTime_;

import Entity;

import ship_.ship_;
import terminal_networking_;

import core.time;
import core.thread;

Entity[] world;

void main() {
	world = [new Entity(1000,pvec(5000L,0),vec(-1000,0)), new Entity(1000,pvec(0L,10000),vec(0,-2000))];
	GameDur tickTime = gameDur!"msecs"(1);
	auto terminalServer = new TerminalServer();
	auto ship = new Ship();
	while (true) {
		////world.each!writeEntity;
		
		Entity[] canMoveEntities = [];
		entityLoop:
		foreach (entity; world) {
			// Hurumf , I am checking collision for every entity twice!?
			foreach (other; world) {
				if (entity==other) continue;
				if (distance(VecLine!long(entity.pos, entity.vel.timedVel(tickTime)), VecLine!long(other.pos, other.vel.timedVel(tickTime))) < entity.radius+other.radius) {
					////"Collision: ".writeln;
					////entity.writeEntity;
					////other.writeEntity;
					continue entityLoop;
				}
			}
			canMoveEntities ~= entity;
		}
		foreach (entity; canMoveEntities)
			entity.pos += entity.vel.timedVel(tickTime);
		
		ship.update(terminalServer.getNewTerminals);
		
		terminal_networking_.sleep(200.msecs);
		////if (readln()=="q")
		////	break;
	}
}


void writeEntity(Entity e) {
	writeln(e.pos,e.vel);
}
