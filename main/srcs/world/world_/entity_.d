module world_.entity_;

import math.tau;

import math.linear.vector;
import math.linear.point;
import world_.game_time_;
import math.loopnum;

alias Pos = PVec2!long;
alias Vel = Vec2!int;
alias Ori = LoopNum!(float,TAU);
alias Anv = float;

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
	
	int radius;
	
	float playAhead = 0.0; // The % of the tick position has been updated for (used in the physics loop).
	
	this (
		int	radius	,
		Pos	pos	= pvec(0L,0),
		Vel	vel	= vec(0,0),
		Ori	ori	= 0f,
		Anv	anv	= 0f,
	){
		this.radius	= radius;
		this.pos	= pos;
		this.vel	= vel;
		this.ori	= ori;
		this.anv	= anv;
	}
}

void writeEntity(Entity e) {
	import std.stdio;
	writeln(e.pos,e.vel);
}



