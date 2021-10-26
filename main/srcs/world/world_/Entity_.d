module world_.Entity_;

import std.traits;
import std.algorithm;

import std.math;
import math.tau;

import math.linear.vector;
import math.linear.point;

import world_.Entity_Object_;
import world_.Physics_World_ : PhysicsOnlyEntity;

public import world_.entity_.Types_;
public import world_.entity_.Physical_State_;
public import world_.entity_.Conv_;

class Entity : PhysicsOnlyEntity {
	union {
		Physical physical;
		struct {
			WorldPos	pos	;
			WorldVel	vel	;
			Ori	ori	;
			Anv	anv	;
			Ana	ana	;
		}
	}
	
	EntityObject object;
	
	WorldPos[] trajectory;
	
	Entity[]	collisions	= [];
	
	bool	alive	= true;
	
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

WorldPos[] traject(Entity entity, Entity[] gravityWells, size_t steps) {
	foreach(i; entity.trajectory.length..steps) {
		WorldPos pos;
		WorldVel vel;
		if (i==0) {
			pos = entity.pos;
			vel = entity.vel;
		}
		else if (i == 1) {
			pos = entity.trajectory[i-1];
			vel = (entity.trajectory[i-1] - entity.pos).castType!WorldVelT;
		}
		else {
			pos = entity.trajectory[i-1];
			vel = (entity.trajectory[i-1] - entity.trajectory[i-2]).castType!WorldVelT;
		}
		entity.trajectory ~= pos+vel+sum(gravityWells.map!(w=>gravitationalVelocity(pos, entity.object, w)));
	}
	return entity.trajectory[0..steps];
}

Imp gravitationalPull(Entity entity, Entity gravityWell) {
	return gravitationalPull(entity.pos, entity.object, gravityWell);
}
Imp gravitationalPull(WorldPos pos, EntityObject object, Entity gravityWell) {
	return	( 0.0001f
		* (cast(float) pow(gravityWell.object.mass +1, 3) -1)
		* (object.mass)
		/ (cast(float) pow(distance(gravityWell.pos.toRelT, pos.toRelT), 2))
		/ 65536f
		* (gravityWell.pos - pos).castType!float.normalized
		)
		.map!(a=>a.isNaN||a.isInfinity?0:a);
}
WorldVel gravitationalVelocity(Entity entity, Entity gravityWell) {
	return gravitationalVelocity(entity.pos, entity.object, gravityWell);
}
WorldVel gravitationalVelocity(WorldPos pos, EntityObject object, Entity gravityWell) {
	return	( 0.0001f
		* (cast(float) pow(gravityWell.object.mass +1, 3) -1)
		/ (cast(float) pow(distance(gravityWell.pos.toRelT, pos.toRelT), 2))
		/ 65536f
		* (gravityWell.pos - pos).castType!float.normalized
		)
		.map!(a=>a.isNaN||a.isInfinity?0:a)
		.fromRelT!WorldVelT;
}

void applyWorldImpulseCentered(Entity entity, Imp impulse) {
	entity.vel += (impulse / entity.object.mass).fromRelT!WorldVelT;
}
void applyWorldImpulseAngular(Entity entity, Ani impulse) {
	entity.anv += (impulse / entity.object.inertia).fromRadians!Anv;
}
void applyWorldImpulse(Entity entity, Imp impulse, RelPos pos) {
	entity.applyWorldImpulseCentered(impulse);
	entity.applyWorldImpulseAngular(cross(pos.vector, impulse));
}

void applyWorldVelocityCentered(Entity entity, WorldVel vel) {
	entity.vel += vel;
}



