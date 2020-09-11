
struct RadarMaster {
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(RadarSlave);
	
	RadarEntityObject[]	_entityObjects	;
	RadarEntity[]	_entities	;
	
	@property auto entityObjects() {
		return _entityObjects;
	}
	@property auto entities() {
		return _entities;
	}
	void addEntityObject(RadarEntityObject n) {
		// TODO: validate.
		_entityObjects ~= n;
		slaves.each!(s=>s._newEntityObjects ~= n);
	}
	void addEntity(RadarEntity n) {
		// TODO: validate.
		_entities ~= n;
		slaves.each!(s=>s._newEntities ~= n);
	}
}

struct RadarSlave {
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(RadarMaster);
	
	RadarEntityObject[]	_entityObjects	;
	RadarEntity[]	_entities	;
	
	RadarEntityObject[]	_newEntityObjects	;
	RadarEntity[]	_newEntities	;
	
	@property auto entityObjects() {
		return _entityObjects;
	}
	@property auto entities() {
		return _entities;
	}
	@property auto newEntityObjects() {
		return _newEntityObjects;
	}
	@property auto newEntities() {
		return _newEntities;
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
