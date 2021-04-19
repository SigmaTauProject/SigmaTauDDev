module ship_.components_.heading_controller_;

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

class HeadingController : Component {
	@Port
	WirePort* controlPort;
	@Port
	WirePort* rotationControllerPort;
	
	this(Ship ship) {
		super(ship);
	}
	
	override void update() {
		rotationControllerPort.setValue(cast(short)(cast(short) (controlPort.value * 32768) - ship.entity.ori) / 32768f / 2);
	}
	
	mixin ComponentMixin!();
}

