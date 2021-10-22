module ship_.components_.twitch_switch_;

import std.experimental.typecons;
import std.algorithm;
import std.range;
import std.math;

import world_;
import math.linear.vector;
import math.linear.point;

import ship_.component_;
 
import ship_.ports_.wire_; 

class TwitchSwitch : Component {
	@Port
	WirePort*[] inPorts;
	@Port
	WirePort* outPort;
	
	bool feedback;
	size_t lastTwitch;
	
	this(Ship ship, bool feedback) {
		super(ship);
		this.feedback = feedback;
	}
	
	override void update() {
		if (outPort is null)
			return;
		foreach (i, p; inPorts) if (p.twitched) {
			lastTwitch = i;
			outPort.twitch;
			break;
		}
		if (lastTwitch < inPorts.length) {
			outPort.setValue(inPorts[lastTwitch].value);
			if (feedback) foreach (p; inPorts)
				p.setValue(outPort.value);
		}
	}
	
	mixin ComponentMixin!();
}

