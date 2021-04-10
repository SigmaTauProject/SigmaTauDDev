module networking_.terminal_connection_;

abstract class TerminalConnection {
	//---Connected
	public {
		@property bool connected();
	}
	
	//---Send
	public {
		uint sentMsgID = 0;// First send will increment and be `1`.
		abstract void send(const(ubyte[]) msg);
	}
	
	//---Receive
	public {
		uint msgID = 0;// ID of last pulled msg.
		abstract bool pullMsg(const(ubyte)[]* msg);
	}
}
