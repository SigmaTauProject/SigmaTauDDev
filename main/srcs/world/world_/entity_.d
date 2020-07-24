module world_.entity_;

import std.traits;

import std.math;
import math.tau;

import math.linear.vector;
import math.linear.point;
import math.loopnum;

import world_.entity_object_;

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
	
	EntityObject object;
	
	float playAhead = 0.0; // The % of the tick position has been updated for (used in the physics loop).
	
	this (
		EntityObject	object	,
		WorldPos	pos	= pvec(0L,0)	,
		WorldVel	vel	= vec(0,0)	,
		Ori	ori	= 0	,
		Anv	anv	= 0	,
	){
		this.object	= object	;
		this.pos	= pos	;
		this.vel	= vel	;
		this.ori	= ori	;
		this.anv	= anv	;
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

float toFloat(T)(T val) if (isIntegral!T) {
	return cast(float) val / 65536;
}
T fromFloat(T)(float val) if (isIntegral!T) {
	return cast(T) (val * 65536);
}


void applyWorldImpulseCentered(Entity entity, Imp impulse) {
	entity.vel += (impulse / entity.object.mass).castType!int;
}
void applyWorldImpulseAngular(Entity entity, Ani impulse) {
	entity.anv += (impulse / entity.object.inertia).anvFromRadians;
}
void applyWorldImpulse(Entity entity, Imp impulse, PVec2!float pos) {
	entity.applyWorldImpulseCentered(impulse);
	entity.applyWorldImpulseAngular(cross(pos.vector, impulse));
}



