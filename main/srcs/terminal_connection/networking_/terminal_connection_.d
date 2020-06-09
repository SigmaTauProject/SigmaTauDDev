module networking_.terminal_connection_;

interface TerminalConnection {
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
