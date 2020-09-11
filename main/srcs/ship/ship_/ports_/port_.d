

mixin template PortMaster(Slave) {
	Slave*[] slaves;
	
	void plugIn(Slave* slave) {
		slaves ~= slave;
		assert(!slave.master);
		slave.master = &this;
	}
	void unplug(Slave* slave) {
		slaves = slaves.remove(slave);
		slave.master = null;
	}
}

mixin template PortSlave(Master) {
	Master* master;
}


