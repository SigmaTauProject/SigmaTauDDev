module ship_.ship_;

import std.algorithm;
import accessors;

import watch_var_;
import ship_.components_;
import ship_.ports_;
import ship_.bridge_;

import terminal_networking_;



class Ship {
	Hardware hardware;
	TerminalConnection[] terminals = [];
	this () {
		hardware = new Hardware;
		hardware.bridge = new Bridge;
		hardware.thrusters ~= new Thruster;
		{
			auto wire = new WireOutPort(0);
			// Listener needs memory managed.
			wire.value.listen((v){hardware.thrusters[0].thrust = v;});
			hardware.bridge.addPort(wire);
		}
	}
	void update(TerminalConnection[] newTerminals) {
		newTerminals.each!((t){
			// ... Send initial msg
		});
		terminals ~= newTerminals;
	}
}

class Hardware {
	Bridge	bridge;
	
	Thruster[] thrusters;
	Radar[] radars;
}


 
