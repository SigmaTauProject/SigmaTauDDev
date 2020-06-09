module world_.world_;

import std.algorithm;

import world_.entity_;
import world_.game_time_;

import math.linear.vector;
import math.linear.point;
import math.geometry.line;

class World {
	Entity[] entities;
	
	GameDur tickTime = gameDur!"msecs"(1);
	
	this() {
		entities = [new Entity(1000,pvec(5000L,0),vec(-1000,0)), new Entity(1000,pvec(0L,10000),vec(0,-2000))];
	}
	
	void update() {
		////entities.each!writeEntity;
		
		Entity[] canMoveEntities = [];
		entityLoop:
		foreach (entity; entities) {
			// Hurumf , I am checking collision for every entity twice!?
			foreach (other; entities) {
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
	}
}
