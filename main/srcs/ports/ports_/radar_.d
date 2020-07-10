module ports_.radar_;

import accessors;
import structuredrpc;

import ports_.port_;
import ports_.wire_;

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
	float[2] vel;
}

alias RadarPort	= WirePortBase!(WirePortType.wireIn, RadarData)	;

