module ship_.components_.heading_controller_;

import std.experimental.typecons;
import std.algorithm;
import std.range;
import std.math;

import world_.world_;
import world_.entity_;
import world_.entity_object_;
import world_.entity_view_;
import math.linear.vector;
import math.linear.point;

import ship_.component_;
 
import ship_.ports_.wire_; 

class HeadingController : Component {
	@Port
	WirePort* controlPort;
	@Port
	WirePort* thrusterPort;
	
	this(Ship ship) {
		super(ship);
	}
	
	int lastAnv = 0;
	
	override void update() {
		if (controlPort is null || thrusterPort is null)
			return;
		
		////const calcForward = 2;
		////
		////auto forwardOri = cast(short) (ship.entity.ori + ship.entity.anv*calcForward);
		////
		////auto accel = ship.entity.anv - lastAnv;
		////lastAnv = ship.entity.anv;
		////
		////
		////
		////rotationControllerPort.setValue(cast(short)(cast(short) (controlPort.value * 32768) - ship.entity.ori) / 32768f / 1);
		
		////auto maxA = 64;// u/s/s
		
		////auto a = ();
		
		////auto t = -(ship.entity.anv/a);
		
		////v = 0 at 
		
		////a = (2*(cast(short)(cast(short) (controlPort.value * 32768) - ship.entity.ori))/
		
		////if (cast(short)(cast(short) (controlPort.value * 32768) - ship.entity.ori) == 0) {
		////	thrusterPort.setValue(0);
		////}
		////else {
		////	import std.stdio;
		////	auto a = - cast(float) pow(ship.entity.anv, 2) / pow(cast(float) cast(short) (cast(short) (controlPort.value * 32768) - ship.entity.ori), 2);
		////	writeln(pow(ship.entity.anv, 2), " / ", cast(short)(cast(short) (controlPort.value * 32768) - ship.entity.ori), " = ", a);
		////	////if (abs(a) < 0.8)
		////	////	thrusterPort.setValue(-0.8*sgn(cast(short)(cast(short) (controlPort.value * 32768) - ship.entity.ori)));
		////	////else
		////	////	thrusterPort.setValue(a);
		////}
		
		////import std.stdio;
		auto a = anvFromRadians((1/ 8f) / ship.entity.object.inertia);
		short d = cast(short) (cast(short) (controlPort.value * 32768) - ship.entity.ori);
		auto sq = a*d*2f;
		if (ship.entity.anv == 0)
			ship.entity.anv = cast(int) copysign(sqrt(abs(sq)), sq);
		thrusterPort.setValue(clamp(-ship.entity.anv.toRadians*8*ship.entity.object.inertia, -1, 1));
		////writeln(-ship.entity.anv/a);
		////writeln(d, " at ", ship.entity.anv);
	}
	
	mixin ComponentMixin!();
}

