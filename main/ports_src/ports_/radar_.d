module ports_.radar_;

import accessors;
import structuredrpc;
import ports_.port_;

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
alias RadarEntity = float[2];
