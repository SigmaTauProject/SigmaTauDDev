module world_.entity_object_;

import std.math;
import math.tau;

import math.linear.vector;

import world_.entity_;


class EntityObject {
	CollisionPoly collisionPoly;
	
	int broadRadius;
	
	float	mass	;
	float	inertia	;
	
	this(CollisionPoly collisionPoly, int broadRadius) {
		this.collisionPoly = collisionPoly;
		this.broadRadius = broadRadius;
		auto r2 = broadRadius.toFloat * broadRadius.toFloat;
		this.mass	= r2 * PI	;
		this.inertia	= mass * r2 / 2	;
	}
}

struct CollisionPoly {
	Vec2!float[] points;
}

__gshared auto shipObject = new  EntityObject(CollisionPoly([vec(-0.7f,0.7f), vec(0f,-1f), vec(0.7f,0.7f), vec(0f,0.25f)]), 65536);
__gshared auto fineShipObject = new EntityObject(CollisionPoly([vec(-0.7f,0.7f), vec(-1.25f,0f), vec(-0.5f,0f), vec(0f,-1.25f), vec(0.5f,0f), vec(1.25f,0), vec(0.7f,0.7f), vec(0f,0.25f)]), 65536/4*5);
__gshared auto bulletObject = new EntityObject(CollisionPoly([vec(-0.7f/4f,0.7f/4), vec(0f,-0.25f), vec(0.7f/4,0.7f/4), vec(0f,0.25f)]), 65536/4);

