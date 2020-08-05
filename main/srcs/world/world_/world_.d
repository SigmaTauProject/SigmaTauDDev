module world_.world_;

import std.math;
import std.algorithm;

import world_.entity_;

import math.linear.vector;
import math.linear.point;
import math.geometry.line;

import world_.physics_world_;

class World {
	PhysicsWorld physicsWorld;
	Entity[] newEntities = [];
	
	this() {
		physicsWorld = new PhysicsWorld;
	}
	
	@property
	Entity[] entities() {
		return physicsWorld.entities;
	}
	
	void update() {
		newEntities.length = 0;
		newEntities.assumeSafeAppend;
		physicsWorld.update;
	}
	
	void addEntity(Entity entity) {
		physicsWorld.entities ~= entity;
		newEntities ~= entity;
	}
}








