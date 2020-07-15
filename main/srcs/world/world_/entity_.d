module world_.entity_;

import std.math;
import math.tau;

import math.linear.vector;
import math.linear.point;
import world_.game_time_;
import math.loopnum;

alias Pos = PVec2!long;
alias Vel = Vec2!int;
alias Ori = ushort;
alias Anv = int;

Vec2!long timedVel(Vel vel, GameDuration dur) {
	return vel.castType!long * (dur.duration);
}
float timedAnv(Anv anv, GameDuration dur) {
	return anv * (dur.duration);
}

class Entity {
	Pos	pos	;
	Vel	vel	;
	Ori	ori	;
	Anv	anv	;
	
	int	mass	;
	int	inertia	;
	
	int radius;
	
	float playAhead = 0.0; // The % of the tick position has been updated for (used in the physics loop).
	
	this (
		int	radius	,
		Pos	pos	= pvec(0L,0),
		Vel	vel	= vec(0,0),
		Ori	ori	= 0,
		Anv	anv	= 0,
	){
		this.radius	= radius;
		this.pos	= pos;
		this.vel	= vel;
		this.ori	= ori;
		this.anv	= anv;
		this.mass	= cast(int) (cast(float) radius * radius * PI) / 35536;
	}
}

struct EntityView {
	Entity entity	;
	Entity root	;
	
	alias entity this;
	
	PVec2!float pos() {
		return (entity.pos - root.pos).castType!float.rotate(root.ori.toRadians).point;
	}
	Vec2!float vel() {
		return (entity.vel - root.vel).castType!float.rotate(root.ori.toRadians);
	}
	ushort ori() {
		return cast(ushort)(entity.ori - root.ori);
	}
	float rOri() {
		return ori.toRadians;
	}
	float rAnv() {
		return anv.toRadians;
	}
	
	void pos(PVec2!float v) {
		entity.pos = point(v.vector.rotate(- root.ori.toRadians).castType!long + root.pos.vector);
	}
	void vel(PVec2!float v) {
		entity.vel = v.vector.rotate(- root.ori.toRadians).castType!int + root.vel;
	}
	void ori(ushort v) {
		entity.ori = cast(ushort)(v + root.ori);
	}
}

float toRadians(Ori a) {
	return cast(float) a  * (TAU / 65536);
}
float toRadians(Anv a) {
	return cast(float) a  * (TAU / 65536);
}
Anv fromRadians(float a) {
	return cast(Anv) ((a * 65536) / TAU);
}

void writeEntity(Entity e) {
	import std.stdio;
	writeln(e.pos,e.vel);
}


void applyImpulse(EntityView entity, Vec2!float impulse) {
	entity.vel += impulse / entity.mass;
}
void applyImpulse(EntityView entity, float impulse) {
	entity.entity.applyImpulse(impulse.fromRadians);
}
void applyImpulse(EntityView entity, Vec2!float impulse, PVec2!float pos) {
	entity.applyImpulse(impulse);
	entity.applyImpulse(cross(pos.vector, impulse));
}

void applyImpulse(EntityView entity, Anv impulse) {
	entity.anv += impulse / entity.inertia;
}

void applyImpulse(Entity entity, Vel impulse) {
	entity.vel += impulse / entity.mass;
}
void applyImpulse(Entity entity, Anv impulse) {
	entity.anv += impulse /entity.inertia;
}



