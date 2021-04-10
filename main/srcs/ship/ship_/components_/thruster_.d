module ship_.components_.thruster_;

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
 
import ship_.ports_.wire_;

abstract
class ThrusterBase : Component {
	@MasterPort
	WireMaster port;
	
	this(Ship ship) {
		super(ship);
	}
}
class DirectThruster : ThrusterBase {
	enum Type {
		fore	,
		side	,
		rot	,
	}
	Type type;
	
	this(Ship ship, Type type) {
		super(ship);
		this.type = type;
	}
	
	override void update() {
		final switch (type) {
			case Type.fore:
				ship.entity.applyImpulseCentered(vec(port.value, 0));
				break;
			case Type.side:
				ship.entity.applyImpulseCentered(vec(0, port.value));
				break;
			case Type.rot:
				ship.entity.applyImpulseAngular(port.value/25);
				break;
		}
	}
	
	mixin ComponentMixin!();
}

