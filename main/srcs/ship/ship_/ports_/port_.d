

struct PortMaster {
	ShipPortSlave*[] slaves;
	
	void plugIn(ShipPortSlave* slave) {
		slaves ~= slave;
		assert(!slave.master);
		slave.master = &this;
	}
	void unplug(ShipPortSlave* slave) {
		slaves = slaves.remove(slave);
		slave.master = null;
	}
}

struct PortSlave {
	ShipPortMaster* master;
}


