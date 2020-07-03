module networking_.terminal_connection_;

interface TerminalConnection {
	//---Connected
	public {
		@property bool connected();
	}
	
	//---Send
	public {
		void put(const(ubyte[]) msg);
	}
		
	//---Receive
	public {
		@property bool empty();
		@property const(const(ubyte)[]) front();
		void popFront();
	}
}
