module ship_.ports_;

import watch_var_;

class Port {
}
class WireOutPort : Port {
	WatchVar!float value;
	this (float value) {
		this.value = WatchVar!float(value);
	}
}
class RadarPort : Port {
}

