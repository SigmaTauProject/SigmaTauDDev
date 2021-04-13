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

import ship_.components_.component_;
 
import ship_.ports_.radar_;

class Radar : Component {
	@MasterPort
	RadarMaster port;
	
	Entity[] entities;
	
	this(Ship ship) {
		super(ship);
		
		this.update(ship.world.entities);
	}
	
	override void update() {
		update(ship.world.newEntities);
	}
	void update(Entity[] newEntities) {
		entities ~= newEntities;
		uint[] removedEntities = [];
		foreach_reverse(i,e; entities) {
			if (!e.alive) {
				removedEntities ~= cast(uint) i;
				entities = entities.remove(i);
			}
		}
		port.change(
			ship.world.newEntities.map!(e=>RadarEntityObject(e.object.broadRadius.toFloat, cast(float[2][]) e.object.collisionPoly.points)).array,
			removedEntities,
			entities.map!(e=>EntityView(e, ship.entity)).map!(e=>RadarEntity(e.pos.vector.data, e.ori, e.vel.data)).array,
		);
	}
	
	mixin ComponentMixin!();
}


