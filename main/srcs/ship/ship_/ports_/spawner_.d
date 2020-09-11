
struct SpawnerMaster {
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(SpawnerSlave);
	
	SpawnerEntity[] _spawns;
	
	@property float spawns() {
		return _spawns;
	}
	
	void postUpdate() {
		_spawns.length = 0;
	}
}

struct SpawnerSlave {
	// Mixins are basically a form of inheritance.
	mixin PortSlave!(SpawnerMaster);
	
	void spawn(SpawnerEntity n) {
		if (master)
			master._spawns ~= n;
	}
}

alias SpawnerEntity = float[2];

