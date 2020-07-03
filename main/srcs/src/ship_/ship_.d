module ship_.ship_;

import std.algorithm;
import std.range;
import accessors;

import world_.world_;

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
	
	World world;
	
	this (World world) {
		this.world = world;
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
	
	void installComponent(Component)() {
		components ~= new Component(world);
		
		bridge.plugInPorts(components[$-1].ports);
	}
}



 
