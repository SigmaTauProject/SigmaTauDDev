module ship_.ship_;

import watch_var_;
import ship_.components_;
import ship_.ports_;


class Ship {
	Hardware hardware;
	this () {
		hardware = new Hardware;
		hardware.bridge = new Bridge;
		hardware.thrusters ~= new Thruster;
		{
			auto wire = new WireOutPort(0);
			// Listener needs memory managed.
			wire.value.listen((v){hardware.thrusters[0].thrust = v;});
			hardware.bridge.wireOuts.addValue(wire);
		}
	}
}

class Hardware {
	Bridge	bridge;
	
	Thruster[] thrusters;
	Radar[] radars;
}
class Bridge {
	WatchArray!WireOutPort wireOuts;
	WatchArray!RadarPort radar;
}


 
