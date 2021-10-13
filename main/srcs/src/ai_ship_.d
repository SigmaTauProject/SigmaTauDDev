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

import ship_controller_;

import ship_.ship_;

class AIShip : ShipController {
	World world;
	
	Entity entity;
	Ship ship;
	
	EntityView target;
	
	this (World world) {
		this.world = world;
		
		entity = new Entity(shipObject,pvec(-96.fromFloat!long,16.fromFloat!long),vec(0,0), 16384*0);
		ship = new Ship(world, entity);
	}
	
	override void update() {
		if (!target) {
			try {
				target = EntityView(world.entities.find!(e=>e.object==fineShipObject)[0], entity);
			}
			catch (RangeError) {}
			return;
		}
		
		ship.bridge.wires[3].setValue(atan2(cast(float) target.entity.pos.y-target.root.pos.y, cast(float) target.entity.pos.x-target.root.pos.x)/PI);
		
		if (100 > abs(entity.ori - atan2(cast(float) target.entity.pos.y-target.root.pos.y, cast(float) target.entity.pos.x-target.root.pos.x).oriFromRadians)) {
			ship.bridge.pings[0].ping;
		}
		
		ship.update	;
	}
}
