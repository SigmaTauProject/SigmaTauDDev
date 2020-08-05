module world_.entity_view_;

import world_.entity_;

import std.math;
import math.tau;

import math.linear.vector;
import math.linear.point;
import math.loopnum;

alias RelPos = PVec2!float;
alias RelVel = Vec2!float;


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
	return ((pos - root.pos).castType!float / 65536).rotate(- root.ori.toRadians).point;
}
WorldPos posRel(RelPos pos, Entity root) {
	return point((pos.vector.rotate(root.ori.toRadians) * 65536).castType!long + root.pos.vector);
}

RelVel relVel(WorldVel vel, Entity root) {
	return ((vel - root.vel).castType!float / 65536).rotate(- root.ori.toRadians);
}
WorldVel velRel(RelVel vel, Entity root) {
	return (vel.rotate(root.ori.toRadians) * 65536).castType!int + root.vel;
}

Ori relOri(Ori ori, Entity root) {
	return cast(ushort)(ori - root.ori);
}
Ori oriRel(Ori ori, Entity root) {
	return cast(ushort)(ori + root.ori);
}


void applyImpulseCentered(Entity entity, Imp impulse) {
	entity.vel += ((impulse / entity.object.mass) * 65536).rotate(entity.ori.toRadians).castType!int;
}
void applyImpulseAngular(Entity entity, Ani impulse) {
	entity.anv += (impulse / entity.object.inertia).anvFromRadians;
}
void applyImpulse(Entity entity, Imp impulse, RelPos pos) {
	entity.applyImpulseCentered(impulse);
	entity.applyImpulseAngular(cross(pos.vector, impulse));
}



