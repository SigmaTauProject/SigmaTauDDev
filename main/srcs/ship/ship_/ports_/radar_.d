module ship_.ports_.radar_;

import std.algorithm;

struct RadarPort {
	RadarPort**[] connections;
	
	//---POD
	RadarEntityObject[]	entityObjects	;
	RadarEntity[]	entities	;
	
	RadarEntityObject[]	newEntities	;
	uint[]	removedEntities	;
	
	void change(RadarEntityObject[] newEntities, uint[] removedEntities, RadarEntity[] entities) {
		entityObjects ~= newEntities;
		foreach(e; removedEntities)
			entityObjects = entityObjects.remove(e);
		
		this.entities	= entities	;
		this.newEntities	= newEntities	;
		this.removedEntities	= removedEntities	;
	}
}

struct RadarEntityObject {
	float radius;
	float[2][] shape;
}
struct RadarEntity {
	float[2] pos;
	ushort ori;
	float[2] vel;
}
