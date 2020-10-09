module ship_.components_.component_;

import std.experimental.typecons;
import std.algorithm;
import std.range;

import world_.world_;
import world_.entity_;
import world_.entity_object_;
import world_.entity_view_;
import math.linear.vector;
import math.linear.point;

abstract
class Component {
	Ship ship;
	
	this(Ship ship) {
		this.ship = ship;
		_portsInternalInit;
	}
	
	void update() {}
	
	//---private
	abstract void _portsInternalInit();
}
template ComponentMixin() {
	import std.traits;
	
	override void _portsInternalInit() {
	}
}

abstract class Ship {
	World world;
	Entity entity;
}

enum MasterPort;
enum SlavePort;

