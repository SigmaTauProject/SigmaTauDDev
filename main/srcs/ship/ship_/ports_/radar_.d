module ship_.ports_.radar_;


struct RadarMaster {
	//---POD
	RadarEntityObject[]	entityObjects	;
	RadarEntity[]	entities	;
	
	NetRadarConnection net;
	
	void change(RadarEntityObject[] newEntities, uint[] removedEntities, RadarEntity[] entities_) {
		import std.algorithm;
		entityObjects ~= newEntities;
		foreach(e; removedEntities)
			entityObjects = entityObjects.remove(e);
		entities = entities_;
		
		if (net) net.onChange(newEntities, removedEntities);
	}
	
	@property
	RadarSlave* slave() {
		return cast(RadarSlave*) &this;
	}
}

struct RadarSlave {
	//---POD
	const RadarEntityObject[]	entityObjects	;
	const RadarEntity[]	entities	;
	
	NetRadarConnection net;
}

abstract class NetRadarConnection {
	RadarSlave* port;
	
	this(RadarSlave* port) {
		this.port = port;
		port.net = this;
		onChange(port.entityObjects, cast(uint[])[]);
	}
	
	abstract void onChange(const RadarEntityObject[] newEntities, uint[] removedEntities);
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
