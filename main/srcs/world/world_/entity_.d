module world_.entity_;

import std.math;
import math.tau;

import math.linear.vector;
import math.linear.point;
import math.loopnum;

alias WorldPos = PVec2!long;
alias WorldVel = Vec2!int;
alias Ori = ushort;
alias Anv = int;

alias Radians = float;

alias Imp = Vec2!float;
alias Ani = float;


class Entity {
	WorldPos	pos	;
	WorldVel	vel	;
	Ori	ori	;
	Anv	anv	;
	
	float	mass	;
	float	inertia	;
	
	int radius;
	
	float playAhead = 0.0; // The % of the tick position has been updated for (used in the physics loop).
	
	this (
		int	radius	,
		WorldPos	pos	= pvec(0L,0),
		WorldVel	vel	= vec(0,0),
		Ori	ori	= 0,
		Anv	anv	= 0,
	){
		this.radius	= radius;
		this.pos	= pos;
		this.vel	= vel;
		this.ori	= ori;
		this.anv	= anv;
		auto r2 = cast(float) radius * radius;
		this.mass	= r2 * PI;
		this.inertia	= mass * r2 / 2;
	}
}


Radians toRadians(Ori a) {
	return cast(Radians) a * (TAU / 65536);
}
Radians toRadians(Anv a) {
	return cast(Radians) a * (TAU / 65536);
}
Ori oriFromRadians(Radians a) {
	return cast(Ori) ((a * 65536) / TAU);
}
Anv anvFromRadians(Radians a) {
	return cast(Anv) ((a * 65536) / TAU);
}


void applyWorldImpulseCentered(Entity entity, Imp impulse) {
	entity.vel += (impulse / entity.mass).castType!int;
}
void applyWorldImpulseAngular(Entity entity, Ani impulse) {
	entity.anv += (impulse / entity.inertia).anvFromRadians;
}
void applyWorldImpulse(Entity entity, Imp impulse, PVec2!float pos) {
	entity.applyWorldImpulseCentered(impulse);
	entity.applyWorldImpulseAngular(cross(pos.vector, impulse));
}



