module ship_.components_.rotation_controller_;

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

import ship_.components_.component_;
 
import ship_.ports_.wire_; 

class RotationController : Component {
	@MasterPort
	WireMaster controlPort;
	@SlavePort
	WireSlave* thrusterPort;
	
	this(Ship ship) {
		super(ship);
	}
	
	override void update() {
		thrusterPort.setValue(clamp((pow(abs(controlPort.value)*16,2)*128*sgn(controlPort.value) - ship.entity.anv)/512, -1, 1));
	}
	
	mixin ComponentMixin!();
}

