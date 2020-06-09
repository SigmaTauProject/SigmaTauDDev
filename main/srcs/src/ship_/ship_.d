module ship_.ship_;

import std.algorithm;
import std.range;
import accessors;

import ship_.components_;
import ports_.port_;
import ports_.bridge_;
import ports_.wire_;
import ports_.radar_;

import networking_.terminal_connection_;

class Ship {
	Hardware hardware;
	Bridge!true bridge;
	TerminalConnection[] terminals = [];
	this () {
		hardware = new Hardware;
		bridge = new Bridge!true;
		hardware.thrusters ~= new Thruster;
		{
			auto radar = bridge.addPort!(PortType.radar)(new RadarData([]));
			auto wire = bridge.addPort!(PortType.wire)(0);
			// Listener needs memory managed.
			////wire.value.listen((v){hardware.thrusters[0].thrust = v;});
		}
	}
	void update(TerminalConnection[] newTerminals) {
		bridge.newClients(newTerminals);
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


 
