module world_.World_;

import std.math;
import std.algorithm;

import world_.Entity_;

import math.linear.vector;
import math.linear.point;
import math.geometry.line;

import world_.Physics_World_;

class World {
	PhysicsWorld physicsWorld;
	Entity[] newEntities = [];
	Entity[] nextEntities = [];
	
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
		
		foreach (entity; nextEntities) {
			physicsWorld.entities ~= entity;
			newEntities ~= entity;
		}
		
		nextEntities.length = 0;
		nextEntities.assumeSafeAppend;
		
		physicsWorld.update;
	}
	
	void addEntity(Entity entity) {
		nextEntities ~= entity;
	}
}








