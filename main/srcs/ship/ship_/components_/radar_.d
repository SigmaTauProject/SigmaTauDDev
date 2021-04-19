module ship_.components_.radar_;

import std.experimental.typecons;
import std.algorithm;
import std.range;

import world_.world_;
import world_.entity_;
import world_.entity_object_;
import world_.entity_view_;
import math.linear.vector;
import math.linear.point;

import ship_.component_;
 
import ship_.ports_.radar_;

class Radar : Component {
	@Port
	RadarPort* port;
	RadarPort* lastPort;
	
	Entity[] entities;
	
	this(Ship ship) {
		super(ship);
	}
	
	override void update() {
		if (port is null) return;
		if (port != lastPort) {
			update(ship.world.entities);
			lastPort = port;
		}
		else {
			update(ship.world.newEntities);
		}
	}
	void update(Entity[] newEntities) {
		assert(port !is null);
		entities ~= newEntities;
		uint[] removedEntities = [];
		foreach_reverse(i,e; entities) {
			if (!e.alive) {
				removedEntities ~= cast(uint) i;
				entities = entities.remove(i);
			}
		}
		port.change(
			newEntities.map!(e=>RadarEntityObject(e.object.broadRadius.toFloat, cast(float[2][]) e.object.collisionPoly.points)).array,
			removedEntities,
			entities.map!(e=>EntityView(e, ship.entity)).map!(e=>RadarEntity(e.pos.vector.data, e.ori, e.vel.data)).array,
		);
	}
	
	mixin ComponentMixin!();
}


