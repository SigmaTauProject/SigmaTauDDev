module ship_.components_.missile_tube_;

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
 
import ship_.ports_.ping_;

class MissileTube : Component {
	@Port
	PingPort* port;
	
	int loading = 16;
	
	this(Ship ship) {
		super(ship);
	}
	
	override void update() {
		if (loading)
			loading --;
		else if (port.pings) {
			ship.world.addEntity(new Entity(bulletObject, ship.entity.pos, vec(2f,0).velRel(ship.entity), ship.entity.ori));
			loading = 16;
		}
	}
	
	mixin ComponentMixin!();
}

