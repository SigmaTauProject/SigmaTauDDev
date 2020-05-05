module ship_.terminal_;

/**	Ship Ports View of a Terminal Connection
*/
struct Terminal {
	/// Save even if not alive.
	void delegate(ubyte[]) sendMsg;
	/// Should be cleaned.
	bool delegate() alive;
}
 
