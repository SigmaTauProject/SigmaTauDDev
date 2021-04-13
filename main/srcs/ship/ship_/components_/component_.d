module ship_.components_.component_;

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
		_portsInternalInit;
	}
	
	void update() {}
	
	//---private
	abstract void _update();
	abstract void _portsInternalInit();
	abstract void _portsInternalPostUpdate();
}
mixin template ComponentMixin() {
	import std.traits;
	
	override void _portsInternalInit() {
		static foreach (mem; __traits(allMembers, typeof(this))) {
			static if (hasUDA!(__traits(getMember, this, mem), MasterPort)) {
				__traits(getMember, this, mem) = typeof(__traits(getMember, this, mem))();
				static if (hasMember!(typeof(__traits(getMember, this, mem)), "initialize"))
					__traits(getMember, this, mem).initialize;
			}
		}
	}
	override void _portsInternalPostUpdate() {
		static foreach (mem; __traits(allMembers, typeof(this)))
			static if (hasUDA!(__traits(getMember, this, mem), MasterPort))
				static if (hasMember!(typeof(__traits(getMember, this, mem)), "update"))
					__traits(getMember, this, mem).update;
	}
	override void _update() {
		static foreach (mem; __traits(allMembers, typeof(this)))
			static if (hasUDA!(__traits(getMember, this, mem), MasterPort))
				static if (hasMember!(typeof(__traits(getMember, this, mem)), "earlyUpdate"))
					__traits(getMember, this, mem).earlyUpdate;
		this.update;
		static foreach (mem; __traits(allMembers, typeof(this)))
			static if (hasUDA!(__traits(getMember, this, mem), MasterPort))
				static if (hasMember!(typeof(__traits(getMember, this, mem)), "midUpdate"))
					__traits(getMember, this, mem).midUpdate;
	}
}

abstract class Ship {
	World world;
	Entity entity;
}

enum MasterPort;
enum SlavePort;

