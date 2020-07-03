module ship_.components_;

import std.experimental.typecons;
import std.algorithm;
import std.range;

import world_.world_;
import world_.entity_;
import math.linear.vector;
import math.linear.point;

import ports_.port_;
import ports_.bridge_;
import ports_.wire_;
import ports_.radar_;
import ports_.spawner_;

interface Ship {
}

enum Ports;

abstract
class Component {
	World world;
	Ship ship;
	Port!true[] ports;
	
	this(World world) {
		this.world = world;
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

class Thruster : Component {
	@Ports struct {
		WirePort!true port;
	}
	
	mixin ComponentMixin!();
	
	this(World world) {
		super(world);
		port = new WirePort!true(0);
	}
	
	override void update() {
	}
}
class Radar : Component {
	@Ports struct {
		RadarPort!true port;
	}
	
	mixin ComponentMixin!();
	
	this(World world) {
		super(world);
		port = new RadarPort!true(new RadarData([]));
	}
	
	override void update() {
		port.set(new RadarData(world.entities.map!(e=>e.pos.vector.castType!float.data).array));
	}
}
class Spawner : Component {
	@Ports struct {
		SpawnerPort!true port;
	}
	
	mixin ComponentMixin!();
	
	this(World world) {
		super(world);
		port = new SpawnerPort!true([0,0]);
		port.listen((float[2] entity) {
			world.entities ~= new Entity(1000,point(vec(entity).castType!long),vec(-1000,0));
		});
	}
	
	override void update() {
	}
}
