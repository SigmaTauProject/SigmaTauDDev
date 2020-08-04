module ship_.components_;

import std.experimental.typecons;
import std.algorithm;
import std.range;

import world_.world_;
import world_.entity_;
import world_.entity_object_;
import world_.entity_view_;
import math.linear.vector;
import math.linear.point;

import ports_.port_;
import ports_.bridge_;
import ports_.wire_;

abstract class Ship {
	World world;
	Entity entity;
}

enum Ports;

abstract
class Component {
	Ship ship;
	Port!true[] ports;
	
	this(Ship ship) {
		this.ship = ship;
		_portsInternalInit;
	}
	
	abstract void update();
	
	//---private
	abstract void _portsInternalInit();
}
template ComponentMixin() {
	import std.traits;
	
	override void _portsInternalInit() {
		ports = (cast(Port!true*) &__traits(getMember, this, __traits(identifier, getSymbolsByUDA!(typeof(this), Ports)[0])))[0..getSymbolsByUDA!(typeof(this), Ports).length];
	}
}

abstract
class ThrusterBase : Component {
	@Ports struct {
		WirePort!true port;
	}
	
	mixin ComponentMixin!();
	
	this(Ship ship) {
		super(ship);
		port = new WirePort!true(0);
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
				ship.entity.applyImpulseCentered(vec(port.get*2000, 0));
				break;
			case Type.side:
				ship.entity.applyImpulseCentered(vec(0, port.get*1000));
				break;
			case Type.rot:
				ship.entity.applyImpulseAngular(port.get/25);
				break;
		}
	}
}
