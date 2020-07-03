import cst_;
import std.stdio;
import std.string;
import std.exception;
import std.algorithm;

import world_.world_;

import ship_.ship_;
import networking_.terminal_networking_;

import core.time;
import std.datetime;
import core.thread;

void main() {
	World world = new World;
	auto terminalServer = new TerminalServer();
	auto ship = new Ship(world);
	
	while (true) {
		auto loopStartTime = MonoTime.currTime;
		terminalServer.update;
		world.update;
		ship.update(terminalServer.getNewTerminals);
		
		Thread.sleep(max(0.msecs, 100.msecs - (MonoTime.currTime - loopStartTime)));
		////if (readln()=="q")
		////	break;
	}
}

