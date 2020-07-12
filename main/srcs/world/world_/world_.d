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
		void sweep(bool only=false)(size_t start=0) {
			foreach (e; start..entities.length-1) {
				if (entities[e].pos.x + max(0, entities[e].vel.x) > entities[e+1].pos.x + max(0, entities[e+1].vel.x))
					swap(entities[e], entities[e+1]);
				else static if (only)
					break;
			}
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
					entities[col.o].pos += entities[e].vel * cast(long) ((col.at - entities[e].playAhead) * 65536) / 65536;
					entities[col.o].pos += entities[col.o].vel * cast(long) ((col.at - entities[col.o].playAhead) * 65536) / 65536;
					entities[e].playAhead = col.at;
					entities[col.o].playAhead = col.at;
					//---Collision Resolution
					entities[e].vel = vec([0,0]);
					entities[col.o].vel = vec([0,0]);
					
					//---Correct Sweep
					sweep!true(e);
				}
				
				//---Rehandle entity at this index (might be a new left-most entity)
				handleEntity(e, upTo);
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
	return collisionTime((a.pos.vector - b.pos.vector).castType!float, (b.vel - a.vel).castType!float, cast(float) a.radius + b.radius);
}

float collisionTime(Vec!(float,2) oPos, Vec!(float,2) vel, float r) {
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
	if (ans >= 1 || ans < 0)
		return -1;
	assert(!ans.isNaN);
	return ans;
}

struct Collision {
	size_t o; // entity index
	float at;
}










