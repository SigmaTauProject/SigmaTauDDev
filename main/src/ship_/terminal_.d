module ship_.terminal_;

import terminal_networking_;

alias Terminal = TerminalConnection;

/**	Ship Ports View of a Terminal Connection
*/
////struct Connection(Ts...) {
////	void* id;
////	bool opEqual(Connection!Ts other) {
////		return this.id==other.id;
////	}
////	/// Save even if not alive.
////	void delegate(Ts) sendMsg;
////	/// Should be cleaned.
////	bool delegate() alive;
////}
////
////Terminal connectionToTerminal(TerminalConnection term) {
////	return Terminal(msg=>term.send(msg), ()=>term.connected);
////}

////struct ConnectionListenters(Ts...) {
////	alias Listener = void delegate(Ts);
////	Listener[] listeners = [];
////	void listen(Listener listener) {
////		listeners ~= listener;
////	}
////	void unlisten(Listener listener) {
////		assert(false, "Unimpelmented");
////	}
////	void clean() {
////		listeners = listeners.filter!(l=>l.alive).array;
////	}
////	void call(Ts args) {
////		clean;
////		listeners.each!(l=>l(args));
////	}
////	void call(alias filterPredicate)(Ts args) if (is(typeof(unaryFun!filterPredicate))) {
////		clean;
////		listeners.filter!filterPredicate.each!(l=>l(args));
////	}
////}
 
