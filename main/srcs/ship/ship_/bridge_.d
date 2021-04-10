module ship_.bridge_;

import ship_.components_.component_;

import ship_.ports_.wire_;
import ship_.ports_.radar_;

import ship_.net_ports_.bridge_;
import ship_.net_ports_.wire_;
import ship_.net_ports_.radar_;

class Bridge : Component {
	NetBridgeRoot net;
	
	this(Ship ship) {
		super(ship);
		this.net = new NetBridgeRoot(this);
	}
	
	@SlavePort
	WireSlave*[] wires;
	size_t[] wires_ids = [];
	void wires_plugIn(WireSlave* wire) {
		wires ~= wire;
		wires_ids ~= net.plugInPort(new NetWireRoot(wire));
	}
	
	@SlavePort
	RadarSlave*[] radars;
	size_t[] radars_ids = [];
	void radars_plugIn(RadarSlave* radar) {
		radars ~= radar;
		radars_ids ~= net.plugInPort(new NetRadarRoot(radar));
	}
	
	mixin ComponentMixin!();
}



