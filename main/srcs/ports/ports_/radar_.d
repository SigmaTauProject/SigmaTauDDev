module ports_.radar_;

import accessors;
import structuredrpc;

import ports_.port_;
import ports_.bases_.wire_in_;

import std.traits;
import std.algorithm;
import std.range;
import std.typecons;

class RadarData {
	RadarEntity[] entities;
	
	this(RadarEntity[] entities) {
		this.entities = entities;
	}
}
struct RadarEntity {
	float[2] pos;
	ushort ori;
	float[2] vel;
	float radius;
	float[2][] shape;
}

alias RadarPort	= WireInPortBase!RadarData	;

