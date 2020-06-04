module ship_.ship_;

import std.algorithm;
import std.range;
import accessors;

import ship_.components_;
import ship_.terminal_;
import ship_.ports_.port_;
import ship_.ports_.bridge_;
import ship_.ports_.wire_out_;

import terminal_networking_;



class Ship {
	Hardware hardware;
	Bridge!true bridge;
	TerminalConnection[] terminals = [];
	this () {
		hardware = new Hardware;
		bridge = new Bridge!true;
		hardware.thrusters ~= new Thruster;
		{
			auto wire = bridge.addPort!(PortType.wireOut)(0);
			// Listener needs memory managed.
			////wire.value.listen((v){hardware.thrusters[0].thrust = v;});
		}
	}
	void update(TerminalConnection[] newTerminals) {
		bridge.newTerminals(newTerminals);
		terminals ~= newTerminals;
		
		foreach (term; terminals) {
			foreach (msg; term) {
				bridge.dispatchClientMsg(term, msg);
			}
		}
	}
}

class Hardware {
	Thruster[] thrusters;
	Radar[] radars;
}


 
