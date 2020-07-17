module ship_.ship_;

import std.algorithm;
import std.range;
import accessors;

import world_.world_;
import world_.entity_;

import math.linear.vector;
import math.linear.point;

import ship_.components_;
import ports_.port_;
import ports_.bridge_;
import ports_.wire_;
import ports_.radar_;
import ports_.spawner_;

import networking_.terminal_connection_;

class Ship : ship_.components_.Ship{
	Component[] components = [];
	Bridge!true bridge;
	TerminalConnection[] terminals = [];
	
	// Inherited from ship_.components_.Ship
	//World world;
	//Entity entity;
	
	this (World world) {
		this.world = world;
		entity = new Entity(1000,pvec(0L,0),vec(0,0), 16384*3);
		world.entities ~= entity;
		bridge = new Bridge!true;
		
		installComponent!Radar;
		installComponent!Thruster;
		installComponent!Thruster;
		installComponent!Spawner;
	}
	
	void update(TerminalConnection[] newTerminals) {
		bridge.newClients(newTerminals);
		terminals ~= newTerminals;
		
		foreach (term; terminals) {
			foreach (msg; term) {
				bridge.dispatchClientMsg(term, msg);
			}
		}
		
		components.each!(c=>c.update);
	}
	
	template installComponent(Component) {
		import std.traits;
		static foreach(ctor; __traits(getOverloads, Component, "__ctor"))
		void installComponent(Parameters!ctor[1..$] args) {
			components ~= new Component(this, args);
		bridge.plugInPorts(components[$-1].ports);
	}
}
}



 
