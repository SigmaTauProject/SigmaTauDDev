module ship_.ship_;

import std.algorithm;
import std.range;
import accessors;

import world_.world_;
import world_.entity_;
import world_.entity_object_;
import world_.entity_view_;

import math.linear.vector;
import math.linear.point;

import ship_.components_.component_;
import ship_.bridge_;
import ship_.components_.thruster_;
import ship_.components_.radar_;
import ship_.components_.missile_tube_;

import networking_.terminal_connection_;

class Ship : ship_.components_.component_.Ship {
	Component[] allComponents = [];
	Bridge bridge;
	TerminalConnection[] terminals = [];
	
	// Inherited from ship_.components_.Ship
	//World world;
	//Entity entity;
	
	this (World world) {
		this.world = world;
		entity = new Entity(fineShipObject,pvec(48.fromFloat!long,0.fromFloat!long),vec(0,0), 16384*0);
		world.addEntity(entity);
		bridge = new Bridge(this);
		
		bridge.radars_plugIn(installComponent!Radar.port.slave);
		bridge.wires_plugIn(installComponent!DirectThruster(DirectThruster.Type.fore).port.slave);
		bridge.wires_plugIn(installComponent!DirectThruster(DirectThruster.Type.rot).port.slave);
		bridge.wires_plugIn(installComponent!DirectThruster(DirectThruster.Type.side).port.slave);
		////bridge.connect(installComponent!Spawner.port);
		bridge.pings_plugIn(installComponent!MissileTube.port.slave);
	}
	
	void update() {
		foreach (c; allComponents) {
			c.update;
		}
		foreach (c; allComponents) {
			c._portsInternalPostUpdate;
		}
	}
	
	template installComponent(Component) {
		import std.traits;
		static foreach(ctor; __traits(getOverloads, Component, "__ctor"))
		auto installComponent(Parameters!ctor[1..$] args) {
			auto comp = new Component(this, args);
			allComponents ~= comp;
			return comp;
		}
	}
}



 
