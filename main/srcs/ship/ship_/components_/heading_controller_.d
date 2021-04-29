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
		
		import std.stdio;
		float ma = anvFromRadiansf((1/ 8f) / ship.entity.object.inertia);
		float ma8 = ma*0.8f;
		short d = cast(short) (cast(short) (controlPort.value * 32768) - ship.entity.ori);
		////auto sq = (ma*0.8f)*d*2f;
		////auto v = cast(int) copysign(sqrt(abs(sq)), sq);
		////writeln(d, "\t:(",v,"\t- ", ship.entity.anv, "\t) / ", ma, "\t= ",cast(float) (v - ship.entity.anv)/ma);
		
		////thrusterPort.setValue((d-ship.entity.anv*1.5f)/ma);
		
		if (abs(d) <= 1) {
			thrusterPort.setValue(clamp(-ship.entity.anv/ma,-1,1));
		}
		else {
			float a = -(ship.entity.anv*ship.entity.anv) / (d*2f);
			////if (abs(a) < ma8)
			////	write("\033[33m");
			////if (sgn(ship.entity.anv) != sgn(d))
			////	write("\033[32m");
			////if (abs(a) > ma)
			////	write("\033[31m");
			////writeln(ma," ",ma8,"\t ",a,"  \t ",ship.entity.anv,"\t ",d);
			////write("\033[0m");
			////if (sgn(ship.entity.anv+a) != sgn(ship.entity.anv))
			////	writeln("------------------------------");
			if (sgn(ship.entity.anv+a) != sgn(ship.entity.anv))
				thrusterPort.setValue(magClamp((d-ship.entity.anv*1.5f)/ma, 1));
			else if (abs(a) < ma8 || sgn(ship.entity.anv) != sgn(d)) {
				auto ma8d = -ma8*sgn(d);
				float aa = (copysignsqrt(-ma8*(-8f*d + ma8d + 4f*ship.entity.anv)) + ma8d - 2f*ship.entity.anv)/2;
				////if (abs(ship.entity.anv) == 1)
				////	aa = -ship.entity.anv;
				////else if (sgn(d-ship.entity.anv-aa/2) != sgn(d))
				////	aa = d-ship.entity.anv*1.5f;
				////if (aa > 0 && paa > aa)
				////	aa = paa;
				////if (aa < 0 && paa < aa)
				////	aa = paa;
				////writeln((copysignsqrt(-ma8*(-8f*d + ma8d + 4f*ship.entity.anv)) + ma8d - 2f*ship.entity.anv)/2, "\t\t", d-ship.entity.anv*1.5f, "\t\t", aa);
				////thrusterPort.setValue(magClamp((
				////	(copysignsqrt(-ma8*(-8f*d + ma8d + 4f*ship.entity.anv)) + ma8d - 2f*ship.entity.anv)/2
				////)/ma, 1));
				thrusterPort.setValue(magClamp(aa/ma, 1));
			}
			else
				thrusterPort.setValue(clamp(a/ma,-1,1));
			////thrusterPort.setValue(clamp(cast(float) (v - ship.entity.anv)/ma, -1, 1));
			
			////if (ship.entity.anv == 0)
			////	ship.entity.anv = v;
			////thrusterPort.setValue(clamp(-ship.entity.anv.toRadians*8*ship.entity.object.inertia, -0.8, 0.8));
			
			////writeln(-ship.entity.anv/ma);
			////writeln(d, " at ", ship.entity.anv);
		}
	}
	
	mixin ComponentMixin!();
}

T magClamp(T)(T v, T c) {
	assert(c >= 0);
	return clamp(v, -c, c);
}
T magMax(T)(T v, T c) {
	assert(c >= 0);
	if (abs(v) >= c)
		return v;
	if (v >= 0)
		return c;
	else
		return -c;
}


float copysignsqrt(float v) {
	return copysign(sqrt(abs(v)), v);
}
float abssqrt(float v) {
	return sqrt(abs(v));
}

T writelnAnd(T)(T v) {
	import std.stdio;
	writeln(v);
	return v;
}

