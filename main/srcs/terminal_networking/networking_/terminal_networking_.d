module networking_.terminal_networking_;

import hunt.http;
import hunt.io.ByteBuffer;

import std.algorithm;
import std.range;
import std.string;
import std.experimental.logger;
import std.file;
import std.path;

import core.time;
import networking_.terminal_connection_;

/**	Be sure either `sleep` or `proccessEvents` are called routienly
*/
class TerminalServer {
	HttpServer server;
	
	TerminalConnection[] newTerminals;
	
	this() {
		server = HttpServer.builder()
		.setListener(8080, "0.0.0.0")
		.websocket("/ws", new class AbstractWebSocketMessageHandler {
			override void onOpen(WebSocketConnection connection) {
				auto newTerm = new TerminalConnectionImpl(connection);
				newTerminals ~= newTerm;
				terms ~= newTerm;
			}
			override void onBinary(WebSocketConnection connection, ByteBuffer data) {
				terms.find!(t=>t.socket==connection)[0].msgs ~= cast(ubyte[]) data.getRemaining;
			}
		})
		.setHandler(staticRouter("public/terminal"))
		.build();
		
		server.start();
	}
	TerminalConnection[] getNewTerminals() {
		scope(success) newTerminals = [];
		return newTerminals;
	}
	
	void update() {
	}
}

TerminalConnectionImpl[] terms;


class TerminalConnectionImpl : TerminalConnection {
	this (WebSocketConnection socket) {
		this.socket = socket;
	}
	
	WebSocketConnection socket;
	const(ubyte)[][] msgs = [];
	
	@property bool connected() {
		return socket.isConnected;
	}
	
	//---Send
	public {
		void put(const(ubyte[]) msg) {
			if (connected) {
				socket.sendData(cast(byte[]) msg.dup);
			}
		}
	}
		
	//---Receive
	public {
		@property bool empty() {
			return msgs.length == 0;
		}
		@property const(ubyte)[] front() {
			return msgs[0];
		}
		void popFront() {
			assert(!empty);
			msgs = msgs[1..$];
		}
	}
	
}


void delegate(RoutingContext) staticRouter(string path) {
	return (RoutingContext context) {
		string file = context.getURI.toString;
		if (file[0] == '/')
			file = file[1..$];
		auto res = context;
		
		file = buildNormalizedPath(path, file);
		if(file.exists && file.isDir)
			file = buildNormalizedPath(file,"index.html");
		if(!file.exists && file.extension is null)
			file = file.setExtension("html");
		
		if (file.startsWith("../") || file.endsWith("/..") || file == "..") {
			res.setStatus = HttpStatus.NOT_FOUND_404;
		}
		else if(file.exists) {
			if (file.isFile) {
				if (auto mime = file.extension in mimeTypes)
					res.getResponse.header("content-type", *mime);
				res.write = cast(byte[]) read(file);
			}
		}
		else {
			res.setStatus = HttpStatus.NOT_FOUND_404;
		}
		
		context.end();
	};
}

enum string[string] mimeTypes = [
	// text
	".html"	: "text/html",
	".htl"	: "text/html",
	".js"	: "text/javascript",
	".css"	: "text/css",
	".txt"	: "text/plain",
	
	// images
	".png"	: "image/png",
	".jpeg"	: "image/jpeg",
	".jpg"	: "image/jpeg",
	".gif"	: "image/gif",
	".ico"	: "image/x-icon",
	".svg"	: "image/svg+xml",
	
	// other
	".json"	: "application/json",
	".zip"	: "application/zip",
	".bin"	: "application/octet-stream",
];



