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
	int simulationSpeed = 1;
	
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
		
		foreach (_; 0..simulationSpeed)
			physicsWorld.update;
	}
	
	void addEntity(Entity entity) {
		nextEntities ~= entity;
	}
}








