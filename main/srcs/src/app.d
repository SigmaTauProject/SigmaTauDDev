import cst_;
import std.stdio;
import std.string;
import std.exception;
import std.algorithm;

import world_.world_;

import ship_.ship_;
import networking_.terminal_networking_;

import core.time;
import core.thread;

void main() {
	World world = new World;
	auto terminalServer = new TerminalServer();
	auto ship = new Ship(world);
	
	while (true) {
		terminalServer.update;
		world.update;
		
		ship.update(terminalServer.getNewTerminals);
		
		networking_.terminal_networking_.sleep(200.msecs);
		////if (readln()=="q")
		////	break;
	}
}

