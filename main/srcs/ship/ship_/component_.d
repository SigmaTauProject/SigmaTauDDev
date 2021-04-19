module ship_.component_;

import std.experimental.typecons;
import std.algorithm;
import std.range;
import std.traits;

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
	}
	
	void update() {}
}
mixin template ComponentMixin() {
	import std.traits;
}

abstract class Ship {
	World world;
	Entity entity;
}

enum Port;

