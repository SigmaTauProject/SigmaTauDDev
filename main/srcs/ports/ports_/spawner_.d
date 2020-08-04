module ports_.spawner_;

import accessors;
import structuredrpc;

import ports_.port_;
import ports_.bases_.wire_out_;

import std.traits;
import std.algorithm;
import std.range;
import std.typecons;

alias SpawnerEntity = float[2];

alias SpawnerPort	= WireOutPortBase!SpawnerEntity	;

