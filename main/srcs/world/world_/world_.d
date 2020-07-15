module world_.world_;

import std.math;
import std.algorithm;

import world_.entity_;
import world_.game_time_;

import math.linear.vector;
import math.linear.point;
import math.geometry.line;

class World {
	Entity[] entities;
	
	GameDur tickTime = gameDur!"msecs"(1);
	
	this() {
		//r/entities = [new Entity(1000,pvec(5000L,0),vec(-1000,0)), new Entity(1000,pvec(0L,10000),vec(0,-2000))];
		entities = [new Entity(1000,pvec(0L,0),vec(0,0)),];
	}
	
	void update() {
		void sweep() {
			foreach (e; 1 .. entities.length) {
				if (e > 0 && entities[e].pos.x + max(0, entities[e].vel.x) < entities[e-1].pos.x + max(0, entities[e-1].vel.x)) {
					Entity entity = entities[e];
					do {
						entities[e] = entities[e-1];
						e--;
					} while (e > 0 && entities[e].pos.x + max(0, entities[e].vel.x) < entities[e-1].pos.x + max(0, entities[e-1].vel.x));
					entities[e] = entity;
			}
		}
		}
		/// returns new location of e
		size_t resort(size_t e) {
			auto entity = entities[e];
			size_t o;
			if (e < entities.length-1 && entities[e].pos.x + max(0, (entities[e].vel.x * (1 - entities[e].playAhead) * 65536) / 65536) > entities[e+1].pos.x + max(0, (entities[e+1].vel.x * (1 - entities[e+1].playAhead) * 65536) / 65536)) {
				do {
					entities[e] = entities[e+1];
					e++;
				} while (e < entities.length-1 && entities[e].pos.x + max(0, (entities[e].vel.x * (1 - entities[e].playAhead) * 65536) / 65536) > entities[e+1].pos.x + max(0, (entities[e+1].vel.x * (1 - entities[e+1].playAhead) * 65536) / 65536));
				entities[e] = entity;
			}
			else if (e > 0 && entities[e].pos.x + max(0, (entities[e].vel.x * (1 - entities[e].playAhead) * 65536) / 65536) < entities[e-1].pos.x + max(0, (entities[e-1].vel.x * (1 - entities[e-1].playAhead) * 65536) / 65536)) {
				do {
					entities[e] = entities[e-1];
					e--;
				} while (e > 0 && entities[e].pos.x + max(0, (entities[e].vel.x * (1 - entities[e].playAhead) * 65536) / 65536) < entities[e-1].pos.x + max(0, (entities[e-1].vel.x * (1 - entities[e-1].playAhead) * 65536) / 65536));
				entities[e] = entity;
			}
			return e;
		}
		
		// return is if anything happened/changed
		bool handleEntity(size_t e, float upTo=1.0) {//TODO: is ct upTo faster?
			//---Find Collisions
			Collision*[] collisions = [];
			foreach (o; e+1 .. entities.length) {
				auto colTime = collisionTime(entities[e], entities[o]);// colTime will be greater (or equal?) than either entities playAhead
				if (colTime != -1 && colTime < upTo)
					collisions ~= new Collision(o, colTime);
			}
			
			//---Handle Collision
			if (collisions.length) {
				//---Find First Collision
				collisions.partialSort!((a,b)=>a.at<b.at)(1);
				Collision col = *collisions[0];
				
				//---Handle Any Earlier Collision Of Other Entities
				bool anythingHappened = false;
				foreach (i; e+1 .. col.o+1)
					anythingHappened = anythingHappened || handleEntity(i, col.at);
				
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
					
					//---Correct Sweep && Rehandle entity
					e = min(e, resort(e), resort(col.o));
					handleEntity(e, upTo);
				}
				else {
				handleEntity(e, upTo);
				}
				return true;
			}
			return false;
		}
		
		void finishEntity(size_t e) {
			entities[e].pos += entities[e].vel * cast(long) ((1 - entities[e].playAhead) * 65536) / 65536;
			entities[e].playAhead = 1;
		}
		
		//---Sweep
		sweep;
		
		//---Collisions
		foreach (e; 0..entities.length-1) {
			handleEntity(e);
			finishEntity(e);
		}
		finishEntity(entities.length-1);
		
		//---Reset
		entities.each!(e=>e.playAhead=0);
	}
}

float collisionTime(Entity a, Entity b) {
	float playAhead = max(a.playAhead, b.playAhead);
	return collisionTime(((a.pos.vector - a.velTo(playAhead)) - (b.pos.vector - a.velTo(playAhead))).castType!float, (b.vel - a.vel).castType!float, cast(float) a.radius + b.radius, playAhead);
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









