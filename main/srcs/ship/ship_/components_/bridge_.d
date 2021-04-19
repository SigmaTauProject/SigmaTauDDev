module ship_.components_.bridge_;

import std.string;
import std.algorithm;
import std.array;

import ship_.component_;

enum portNames = import("ports.txt").splitLines.filter!(p=>p != "bridge" && p != "").array;

// Auto import ports
// import ship_.ports_.xxx_;
static foreach (port; portNames) {
	mixin("import ship_.ports_."~port~"_;");
}

class Bridge : Component {
	this(Ship ship) {
		super(ship);
	}
	
	static foreach (port; portNames) {
		@Port
		mixin(port.capitalize~"Port*[] "~port~"s;");
		////mixin(port.capitialize~"Port*[] added"~port.capitalize~"s;");
		////mixin(port.capitialize~"Port*[] removed"~port.capitalize~"s;");
		////mixin("struct "~port.capitalize~" { 
		////	"~port.capitialize~"Port* port;
		////	alias port this;
		////	void onPlugIn("~port.capitialize~"Port* port) {added"~port.capitalize~"s ~= port;}
		////	void onUnplug("~port.capitialize~"Port* port) {if (auto index = removed"~port.capitalize~"s.countUntil(port) +1) removed"~port.capitalize~"s = removed"~port.capitalize~"s.remove(index -1);}
		////}";
	}
	
	mixin ComponentMixin!();
}



