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
import ports_.radar_;
import ports_.spawner_;

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
				ship.entity.applyImpulseCentered(vec(port.get, 0));
				break;
			case Type.side:
				ship.entity.applyImpulseCentered(vec(0, port.get));
				break;
			case Type.rot:
				ship.entity.applyImpulseAngular(port.get/25);
				break;
		}
	}
}
class Radar : Component {
	@Ports struct {
		RadarPort!true port;
	}
	
	mixin ComponentMixin!();
	
	this(Ship ship) {
		super(ship);
		port = new RadarPort!true(new RadarData([]));
	}
	
	override void update() {
		port.set(new RadarData(ship.world.entities.map!(e=>EntityView(e, ship.entity)).map!(e=>RadarEntity(e.pos.vector.data, e.ori, e.vel.data, e.object.broadRadius.toFloat, cast(float[2][]) e.object.collisionPoly.points)).array));
	}
}
class Spawner : Component {
	@Ports struct {
		SpawnerPort!true port;
	}
	
	mixin ComponentMixin!();
	
	this(Ship ship) {
		super(ship);
		port = new SpawnerPort!true();
		port.listen((float[2] entity) {
			ship.world.entities ~= new Entity(shipObject, entity.vec.point.posRel(ship.entity), vec(0,1f).velRel(ship.entity), 16384.oriRel(ship.entity));
		});
	}
	
	override void update() {
	}
}
