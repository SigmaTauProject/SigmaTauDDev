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
		return (entity.pos - root.pos).castType!float.rotate(root.ori.toRadians).point;
	}
	RelVel vel() {
		return (entity.vel - root.vel).castType!float.rotate(root.ori.toRadians);
	}
	Ori ori() {
		return cast(ushort)(entity.ori - root.ori);
	}
	float rOri() {
		return ori.toRadians;
	}
	float rAnv() {
		return anv.toRadians;
	}
	
	void pos(RelPos v) {
		entity.pos = point(v.vector.rotate(root.ori.toRadians).castType!long + root.pos.vector);
	}
	void vel(RelVel v) {
		entity.vel = v.rotate(root.ori.toRadians).castType!int + root.vel;
	}
	void ori(ushort v) {
		entity.ori = cast(ushort)(v + root.ori);
	}
}


void applyImpulseCentered(Entity entity, Imp impulse) {
	entity.vel += (impulse / entity.mass).rotate(entity.ori.toRadians).castType!int;
}
void applyImpulseAngular(Entity entity, Ani impulse) {
	entity.anv += (impulse / entity.inertia).anvFromRadians;
}
void applyImpulse(Entity entity, Imp impulse, RelPos pos) {
	entity.applyImpulseCentered(impulse);
	entity.applyImpulseAngular(cross(pos.vector, impulse));
}



