module world_.Entity_View_;

import world_.Entity_;

import std.math;
import math.tau;

import math.linear.vector;
import math.linear.point;

public import world_.entity_.Types_;

struct EntityView {
	Entity entity	;
	Entity root	;
	
	alias entity this;
	
	RelPos pos() {
		return entity.pos.relPos(root);
	}
	RelVel vel() {
		return entity.vel.relVel(root);
	}
	Ori ori() {
		return entity.ori.relOri(root);
	}
	Radians rOri() {
		return ori.toRadians;
	}
	Radians rAnv() {
		return anv.toRadians;
	}
	
	void pos(RelPos pos) {
		entity.pos = pos.posRel(root);
	}
	void vel(RelVel vel) {
		entity.vel = vel.velRel(root);
	}
	void ori(ushort v) {
		entity.ori = ori.oriRel(root);
	}
}


RelPos relPos(WorldPos pos, Entity root) {
	return point((pos - root.pos).toRelT.rotate(- root.ori.toRadians));
}
WorldPos posRel(RelPos pos, Entity root) {
	return point(pos.vector.rotate(root.ori.toRadians).fromRelT!WorldPosT + root.pos.vector);
}

RelVel relVel(WorldVel vel, Entity root) {
	return (vel - root.vel).toRelT.rotate(- root.ori.toRadians);
}
WorldVel velRel(RelVel vel, Entity root) {
	return vel.rotate(root.ori.toRadians).fromRelT!WorldVelT + root.vel;
}

Ori relOri(Ori ori, Entity root) {
	return cast(Ori)(ori - root.ori);
}
Ori oriRel(Ori ori, Entity root) {
	return cast(Ori)(ori + root.ori);
}


void applyImpulseCentered(Entity entity, Imp impulse) {
	entity.vel += (impulse / entity.object.mass).rotate(entity.ori.toRadians).fromRelT!WorldVelT;
}
void applyImpulseAngular(Entity entity, Ani impulse) {
	entity.anv += (impulse / entity.object.inertia).fromRadians!Anv;
}
void applyImpulse(Entity entity, Imp impulse, RelPos pos) {
	entity.applyImpulseCentered(impulse);
	entity.applyImpulseAngular(cross(pos.vector, impulse));
}

void applyForceAngular(Entity entity, float f) {
	entity.ana += (f / entity.object.inertia).fromRadians!Anv;
}



