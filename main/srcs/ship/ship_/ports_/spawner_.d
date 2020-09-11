
struct SpawnerMaster {
	// This line must be here (for every port) (at the vary beginning).  It is a form of inheritance magic.  Changing this will invoke dragons...
	SpawnerSlave*[] slaves;
	
	SpawnerEntity[] _spawns;
	
	@property float spawns() {
		return _spawns;
	}
	
	void postUpdate() {
		_spawns.length = 0;
	}
}

struct SpawnerSlave {
	// This line must be here (for every port) (at the vary beginning).  It is a form of inheritance magic.  Changing this will invoke dragons...
	SpawnerMaster* master;
	
	void spawn(SpawnerEntity n) {
		if (master)
			master._spawns ~= n;
	}
}

alias SpawnerEntity = float[2];

