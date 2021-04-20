module ship_.ship_;

import std.algorithm;
import std.range;
import accessors;
import std.traits;
import std.typecons;

import world_.world_;
import world_.entity_;
import world_.entity_object_;
import world_.entity_view_;

import math.linear.vector;
import math.linear.point;

//---Components
import ship_.component_;

import ship_.components_.bridge_;
import ship_.components_.thruster_;
import ship_.components_.radar_;
import ship_.components_.missile_tube_;
import ship_.components_.spawner_;

import ship_.components_.rotate_controller_;
import ship_.components_.heading_controller_;
//---

class Ship : ship_.component_.Ship {
	Component[] allComponents = [];
	Bridge bridge;
	Tuple!(void*, void delegate())[] allPorts;
	
	// Inherited from ship_.components_.Ship
	//World world;
	//Entity entity;
	
	this (World world, Entity entity) {
		this.world = world;
		this.entity = entity;
		world.addEntity(entity);
		bridge = new Bridge(this);
		
		auto rotThrust = installComponent!DirectThruster(DirectThruster.Type.rot);
		auto rotCon = installComponent!RotateController;
		connect(rotCon.thrusterPort, rotThrust.port);
		auto headCon = installComponent!HeadingController;
		connect(headCon.rotationControllerPort, rotCon.controlPort);
		
		{
			auto comp = installComponent!Radar;
			connect(comp.port, bridge.radars);
		}
		{
			auto comp = installComponent!DirectThruster(DirectThruster.Type.fore);
			connect(comp.port, bridge.wires);
		}
		connect(rotCon.controlPort, bridge.wires);
		{
			auto comp = installComponent!DirectThruster(DirectThruster.Type.side);
			connect(comp.port, bridge.wires);
		}
		{
			auto comp = installComponent!MissileTube;
			connect(comp.port, bridge.pings);
		}
		{
			auto comp = installComponent!Spawner;
			connect(comp.port, bridge.spawners);
		}
		connect(bridge.wires, headCon.controlPort);
		connect(bridge.wires, rotCon.controlPort);
		connect(bridge.wires, rotThrust.port);
	}
	
	void update() {
		foreach (c; allComponents) {
			c.update;
		}
		foreach (p; allPorts) {
			if (p[1] !is null)
				p[1]();
		}
	}
	
	auto connect(PortA, PortB)(ref PortA a, ref PortB b) {
		static if (isDynamicArray!PortA) {
			a.length++;
			auto aImpl = &a[$-1];
		}
		else {
			auto aImpl = &a;
		}
		static if (isDynamicArray!PortB) {
			b.length++;
			auto bImpl = &b[$-1];
		}
		else {
			auto bImpl = &b;
		}
		return connectImpl(*aImpl, *bImpl);
	}
	Port* connectImpl(Port)(ref Port* a, ref Port* b) {
		if (a is null) {
			if (b is null) {
				auto port = new Port();
				static if (__traits(hasMember, Port, "initalize"))
					port.initalize;
				static if (__traits(hasMember, Port, "update"))
					allPorts ~= Tuple!(void*, void delegate())(port, &port.update);
				else
					allPorts ~= Tuple!(void*, void delegate())(port, null);
				port.connections ~= &a;
				port.connections ~= &b;
				a = port;
				b = port;
			}
			else {
				b.connections ~= &a;
				a = b;
			}
		}
		else {
			if (b is null) {
				a.connections ~= &b;
				b = a;
			}
			else {
				foreach (con; b.connections)
					*con = a;
				a.connections ~= b.connections;
				b.connections.length = 0;
			}
		}
		assert(a == b);
		return a;
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



 
