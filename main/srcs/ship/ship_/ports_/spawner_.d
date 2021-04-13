module ship_.ports_.spawner_;


struct SpawnerMaster {
	//---POD
	SpawnInfo[] _spawns = [];
	
	NetSpawnerConnection net;
	
	//---methods
	@property SpawnInfo[] spawns() {
		return _spawns;
	}
	
	void midUpdate() {
		_spawns.length = 0;
		_spawns.assumeSafeAppend;
	}
	
	@property
	SpawnerSlave* slave() {
		return cast(SpawnerSlave*) &this;
	}
}

struct SpawnerSlave {
	//---POD
	SpawnInfo[] _spawns;
	
	NetSpawnerConnection net;
	
	//---methods
	void spawn(SpawnInfo info) {
		_spawns ~= info;
	}
}

abstract class NetSpawnerConnection {
	SpawnerSlave* port;
	
	this(SpawnerSlave* port) {
		this.port = port;
		port.net = this;
	}
	
	void spawn(SpawnInfo info) {
		port._spawns ~= info;
	}
}

alias SpawnInfo = float[2];