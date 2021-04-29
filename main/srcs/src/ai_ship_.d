module ai_ship_;

import core.thread.fiber;
import core.exception;
import std.math;
import std.algorithm;

import world_.world_;
import world_.entity_;
import world_.entity_object_;
import world_.entity_view_;
import math.linear.vector;
import math.linear.point;

import ship_.ship_;

class AIShip : Fiber {
	World world;
	this (World world) {
		this.world = world;
		super(&run);
		call;
	}
	void run() {
		auto entity = new Entity(shipObject,pvec(96.fromFloat!long,16.fromFloat!long),vec(0,0), 16384*0);
		auto ship = new Ship(world, entity);
		
		EntityView target;
		while (true) {
			try {
				target = EntityView(world.entities.find!(e=>e.object==fineShipObject)[0], entity);
				break;
			}
			catch (RangeError) {
				yield;
			}
		}
		
		while (true) {
			yield;
			
			ship.bridge.wires[3].setValue(atan2(cast(float) target.entity.pos.y-target.root.pos.y, cast(float) target.entity.pos.x-target.root.pos.x)/PI);
			
			import std.stdio;
			if (100 > abs(entity.ori - atan2(cast(float) target.entity.pos.y-target.root.pos.y, cast(float) target.entity.pos.x-target.root.pos.x).oriFromRadians)) {
				ship.bridge.pings[0].ping;
			}
			
			ship.update;
		}
	}
}
