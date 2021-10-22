module world_.entity_.Conv_;

import std.math;
import math.tau;
import std.traits;

import math.linear.vector;
import math.linear.point;


public import world_.entity_.Types_;


//---ROTATIONAL
Radians toRadians(T)(T a) {
	return cast(Radians) a * (TAU / 65536);
}
T fromRadians(T)(Radians a) {
	return cast(T) ((a * 65536) / TAU);
}


//---POSITIONAL
RelT toRelT(T)(T val) if (isIntegral!T) {
	return cast(float) val / 65536;
}
T fromRelT(T)(RelT val) if (isIntegral!T) {
	return cast(T) (val * 65536);
}

Vec!(RelT, size) toRelT(T, size_t size)(Vec!(T, size) val) if (isIntegral!T) {
	return val.castType!float / 65536;
}
Vec!(T, size) fromRelT(T, size_t size)(Vec!(RelT, size) val) if (isIntegral!T) {
	return (val * 65536).castType!T;
}

Point!(Vec!(RelT, size)) toRelT(T, size_t size)(Point!(Vec!(T, size)) val) if (isIntegral!T) {
	return point(val.v.toRelT);
}
Point!(Vec!(T, size)) fromRelT(T, size_t size)(Point!(Vec!(RelT, size)) val) if (isIntegral!T) {
	return point(val.v.fromRelT!T);
}

