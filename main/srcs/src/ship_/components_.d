module ship_.components_;

import std.experimental.typecons;
import std.algorithm;
import std.range;

import world_.world_;

import ports_.port_;
import ports_.bridge_;
import ports_.wire_;
import ports_.radar_;

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
		world.entities.each!();
	}
}
