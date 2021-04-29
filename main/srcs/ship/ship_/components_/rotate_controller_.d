module ship_.components_.rotate_controller_;

import std.experimental.typecons;
import std.algorithm;
import std.range;
import std.math;

import world_.world_;
import world_.entity_;
import world_.entity_object_;
import world_.entity_view_;
import math.linear.vector;
import math.linear.point;

import ship_.component_;
 
import ship_.ports_.wire_; 

class RotateController : Component {
	@Port
	WirePort* controlPort;
	@Port
	WirePort* thrusterPort;
	
	this(Ship ship) {
		super(ship);
	}
	
	override void update() {
		if (controlPort is null || thrusterPort is null)
			return;
		thrusterPort._twitched |= controlPort.twitched;
		thrusterPort.setValue(clamp((pow(abs(controlPort.value)*16,2)*128*sgn(controlPort.value) - ship.entity.anv)/256f, -1, 1));
	}
	
	mixin ComponentMixin!();
}

