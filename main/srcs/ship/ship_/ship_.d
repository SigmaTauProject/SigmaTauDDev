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

//---Components
import ship_.components_.component_;
import ship_.bridge_;

import ship_.components_.thruster_;
import ship_.components_.radar_;
import ship_.components_.missile_tube_;
import ship_.components_.spawner_;

import ship_.components_.rotation_controller_;
import ship_.components_.heading_controller_;
//---

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
		
		auto rotThrust = installComponent!DirectThruster(DirectThruster.Type.rot);
		auto rotCon = installComponent!RotationController;
		rotCon.thrusterPort = rotThrust.port.slave;
		auto headCon = installComponent!HeadingController;
		headCon.rotationControllerPort = rotCon.controlPort.slave;
		
		bridge.radars_plugIn(installComponent!Radar.port.slave);
		
		bridge.wires_plugIn(installComponent!DirectThruster(DirectThruster.Type.fore).port.slave);
		bridge.wires_plugIn(rotCon.controlPort.slave);
		bridge.wires_plugIn(installComponent!DirectThruster(DirectThruster.Type.side).port.slave);
		
		bridge.pings_plugIn(installComponent!MissileTube.port.slave);
		
		bridge.wires_plugIn(headCon.controlPort.slave);
		bridge.wires_plugIn(rotCon.controlPort.slave);
		bridge.wires_plugIn(rotThrust.port.slave);
		
		bridge.spawners_plugIn(installComponent!Spawner.port.slave);
	}
	
	void update() {
		foreach (c; allComponents) {
			c._update;
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



 
