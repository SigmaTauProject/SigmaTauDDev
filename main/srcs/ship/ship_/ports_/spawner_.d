module ship_.ports_.spawner_;


struct SpawnerPort {
	SpawnerPort**[] connections;
	
	//---POD
	SpawnInfo[] _spawns = [];
	SpawnInfo[] _nextSpawns = [];
	
	//---methods
	@property SpawnInfo[] spawns() {
		return _spawns;
	}
	
	void spawn(SpawnInfo info) {
		_spawns ~= info;
	}
	
	//---special
	void update() {
		_spawns.length = 0;
		_spawns.assumeSafeAppend;
		
		auto _hold = _spawns;
		_spawns = _nextSpawns;
		_nextSpawns = _hold;
	}
}

alias SpawnInfo = float[2];