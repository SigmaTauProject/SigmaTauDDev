module world_.Physics_World_;

import std.math;
import std.algorithm;

import world_.Entity_;
import world_.Entity_Object_;

import math.linear.vector;
import math.linear.point;
import math.geometry.line;

/// Data used within the physics update, invalid anytime else.
abstract class PhysicsOnlyEntity {
	package(world_):
	
	float playAhead = 0.0; // The % of the tick position has been updated to.
}

class PhysicsWorld {
	Entity[] entities;
	Entity[] gravityWells;
	
	this() {
		//r/entities = [new Entity(1000,pvec(5000L,0),vec(-1000,0)), new Entity(1000,pvec(0L,10000),vec(0,-2000))];
		entities = [];
	}
	
	void update() {
		if (entities.length == 0) return;
		
		void sweep(size_t e) {
			if (e > 0 && entities[e].pos.x + min(0, entities[e].vel.x) - entities[e].object.broadRadius < entities[e-1].pos.x + min(0, entities[e-1].vel.x) - entities[e-1].object.broadRadius) {
				Entity entity = entities[e];
				do {
					entities[e] = entities[e-1];
					e--;
				} while (e > 0 && entity.pos.x + min(0, entity.vel.x) - entity.object.broadRadius < entities[e-1].pos.x + min(0, entities[e-1].vel.x) - entities[e-1].object.broadRadius);
				entities[e] = entity;
			}
		}
		/// returns new location of e
		size_t resort(size_t e) {
			auto entity = entities[e];
			size_t o;
			if (e < entities.length-1 && entities[e].pos.x + min(0, (entities[e].vel.x * (1 - entities[e].playAhead) * 65536) / 65536)  - entities[e].object.broadRadius > entities[e+1].pos.x + min(0, (entities[e+1].vel.x * (1 - entities[e+1].playAhead) * 65536) / 65536)  - entities[e+1].object.broadRadius) {
				do {
					entities[e] = entities[e+1];
					e++;
				} while (e < entities.length-1 && entity.pos.x + min(0, (entity.vel.x * (1 - entity.playAhead) * 65536) / 65536)  - entity.object.broadRadius > entities[e+1].pos.x + min(0, (entities[e+1].vel.x * (1 - entities[e+1].playAhead) * 65536) / 65536)  - entities[e+1].object.broadRadius);
				entities[e] = entity;
			}
			else if (e > 0 && entities[e].pos.x + min(0, (entities[e].vel.x * (1 - entities[e].playAhead) * 65536) / 65536)  - entities[e].object.broadRadius < entities[e-1].pos.x + min(0, (entities[e-1].vel.x * (1 - entities[e-1].playAhead) * 65536) / 65536) - entities[e-1].object.broadRadius) {
				do {
					entities[e] = entities[e-1];
					e--;
				} while (e > 0 && entity.pos.x + min(0, (entity.vel.x * (1 - entity.playAhead) * 65536) / 65536)  - entity.object.broadRadius < entities[e-1].pos.x + min(0, (entities[e-1].vel.x * (1 - entities[e-1].playAhead) * 65536) / 65536) - entities[e-1].object.broadRadius);
				entities[e] = entity;
			}
			return e;
		}
		
		/// return is if anything happened/changed
		bool handleEntity(size_t e, float upTo=1.0) {//TODO: is ct upTo faster?
			//---Find Collisions
			Collision*[] collisions = [];
			{
				auto until = entities[e].pos.x + max(0, entities[e].vel.x) + entities[e].object.broadRadius;
				bool broke = false;
				foreach (o; e+1 .. entities.length) {
					if (until < entities[o].pos.x + min(0, entities[o].vel.x) - entities[o].object.broadRadius)
						break;
					auto colTime = collisionTime(entities[e], entities[o]);// colTime will be greater (or equal?) than either entities playAhead
					if (colTime >= 0 && colTime < upTo)
						collisions ~= new Collision(o, colTime);
				}
			}
			
			//---Handle Collision
			if (collisions.length) {
				//---Find First Collision
				collisions.partialSort!((a,b)=>a.at<b.at)(1);
				Collision col = *collisions[0];
				
				//---Handle Any Earlier Collision Of Other Entities
				bool anythingHappened = false;
				{
					auto until = entities[col.o].pos.x + max(0, entities[col.o].vel.x) + entities[col.o].object.broadRadius;
					foreach (i; e+1 .. entities.length) {
						if (until < entities[i].pos.x + min(0, entities[i].vel.x) - entities[i].object.broadRadius)
							break;
						anythingHappened = anythingHappened || handleEntity(i, col.at);
					}
				}
				
				//---
				if (!anythingHappened) {
					//---Enact Collision
					entities[e].pos += entities[e].velTo(col.at);
					entities[col.o].pos += entities[col.o].velTo(col.at);
					entities[e].playAhead = col.at;
					entities[col.o].playAhead = col.at;
					//---Collision Resolution
					entities[e].vel = vec([0,0]);
					entities[col.o].vel = vec([0,0]);
					//---Collision Responce
					entities[e].collisions ~= entities[col.o];
					entities[col.o].collisions ~= entities[e];
					if ((entities[e].object == bulletObject && (entities[col.o].object==shipObject || entities[col.o].object==fineShipObject)) || (entities[col.o].object == bulletObject && (entities[e].object==shipObject || entities[e].object==fineShipObject))) {
						entities[e].alive = false;
						entities[col.o].alive = false;
						if (e>col.o) {
							entities = entities.remove(e);
							entities = entities.remove(col.o);
						}
						else {
							entities = entities.remove(col.o);
							entities = entities.remove(e);
						}
					}
					
					//---Correct Sweep && Rehandle entity
					e = min(e, e<entities.length?resort(e):size_t.max, col.o<entities.length?resort(col.o):size_t.max);
					handleEntity(e, upTo);
				}
				else {
					handleEntity(e, upTo);
				}
				return true;
			}
			return false;
		}
		
		void startEntity(size_t e) {
			//---Reset
			entities[e].collisions = [];
			
			//////---Gravity
			////foreach (w; gravityWells) {
			////	entities[e].applyWorldImpulseCentered(gravitationalPull(entities[e], w));
			////}
			
			//---Setup
			entities[e].playAhead = 0;
		}
		
		void finishEntity(size_t e) {
			entities[e].pos += entities[e].vel * cast(long) ((1 - entities[e].playAhead) * 65536) / 65536;
			entities[e].playAhead = 1;
			entities[e].ori += entities[e].anv + entities[e].ana/2;
			entities[e].anv += entities[e].ana;
			entities[e].ana = 0;
			foreach (w; gravityWells) {
				entities[e].applyWorldImpulseCentered(gravitationalPull(entities[e], w));
			}
			if (entities[e].trajectory.length) {
				if (entities[e].trajectory[0] == entities[e].pos)
					entities[e].trajectory = entities[e].trajectory[1..$];
				else
					entities[e].trajectory.length = 0;
			}
		}
		
		//---Sweep
		foreach (e; 0..entities.length) {
			startEntity(e);
			if (e != 0)
				sweep(e);
		}
		
		//---Collisions
		for (auto e=0; e<entities.length; e++) {// Length may change during iteration.
			if (e != entities.length-1)
				handleEntity(e);// May shorten entities.
			finishEntity(e);
		}
	}
}

float collisionTime(Entity a, Entity b) {
	float playAhead = max(a.playAhead, b.playAhead);
	return collisionTime(((a.pos.vector - a.velTo(playAhead)) - (b.pos.vector - a.velTo(playAhead))).castType!float, (b.vel - a.vel).castType!float, cast(float) a.object.broadRadius + b.object.broadRadius, playAhead);
}

float collisionTime(Vec!(float,2) oPos, Vec!(float,2) vel, float r, float playAhead=0) {
	auto perp(T)(Vec!(T,2) v) {
		return Vec2!T(v.y, -v.x);
	}
	
	auto v = vel.normalized;
	
	auto y = dot(oPos, v);
	auto x = abs(dot(oPos, perp(v)));
	
	if (x > r)
		return -1;
	float ans;
	if (x == r)
		ans = y;
	else
		ans = y - sqrt(pow(r, 2) - pow(x, 2));
	ans /= vel.magnitude;
	if (ans >= 1 || ans < playAhead)
		return -1;
	assert(!ans.isNaN);
	return ans;
}

struct Collision {
	size_t o; // entity index
	float at;
}


auto velTo(Entity entity, float at) {
	return entity.vel * cast(long) ((at - entity.playAhead) * 65536) / 65536;
}









