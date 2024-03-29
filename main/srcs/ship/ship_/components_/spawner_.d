module ship_.components_.spawner_;

import std.experimental.typecons;
import std.algorithm;
import std.range;

import world_;
import math.linear.vector;
import math.linear.point;

import ship_.component_;
 
import ship_.ports_.spawner_;

class Spawner : Component {
	@Port
	SpawnerPort* port;
	
	this(Ship ship) {
		super(ship);
	}
	
	override void update() {
		foreach (info; port.spawns) {
			ship.world.addEntity(new Entity(shipObject, info.vec.point.posRel(ship.entity), vec(0,0f).velRel(ship.entity), (16384*0).oriRel(ship.entity)));
		}
	}
	
	mixin ComponentMixin!();
}

