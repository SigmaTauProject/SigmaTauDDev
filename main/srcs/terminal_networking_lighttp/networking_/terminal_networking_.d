module networking_.terminal_networking_;

import lighttp;

import std.string;
import std.experimental.logger;
import std.file;
import std.path;

import core.time;
import networking_.terminal_connection_;

/**	Be sure either `sleep` or `proccessEvents` are called routienly
*/
class TerminalServer {
	Server server;
	TerminalRouter terminalRouter;
	
	this() {
		server = new Server();
		server.host("0.0.0.0", 8080);
		server.host("::", 8080);
		server.router.add(new StaticRouter("public/terminal"));
		server.router.add(terminalRouter = new TerminalRouter());
	}
	auto getNewTerminals() {
		scope(success) terminalRouter.newTerminals = [];
		return terminalRouter.newTerminals;
	}
	
	void update() {
		server.eventLoop.loop(0.msecs);
	}
}


class TerminalRouter {
	TerminalConnection[] newTerminals = [];
	@Get(`ws`)
	class TerminalWebSocket : WebSocket {
		bool connected;
		void onConnect(ServerRequest req) {
			import std.stdio; writeln("new");
			writeln(this.conn.isConnected);
			req.writeln;
			newTerminals ~= new TerminalConnectionImpl(this);
			connected = true;
		}
		override void onClose() {
			import std.stdio; writeln("close");
			connected = false;
		}
		
		const(ubyte)[][] msgs;
		
		override void onReceive(ubyte[] data) {
			msgs ~= data.idup;
		}
	}
}
alias TerminalWebSocket = TerminalRouter.TerminalWebSocket;


class TerminalConnectionImpl : TerminalConnection {
	this (TerminalWebSocket socket) {
		this.socket = socket;
	}
	TerminalWebSocket socket;
	
	@property bool connected() {
		return socket.connected && socket.conn.isConnected;
	}
	
	//---Send
	public {
		void put(const(ubyte[]) msg) {
			sentMsgID++;
			if (connected) try {
				socket.send(msg);
			}
			catch (Throwable) {
				socket.connected = false;
			}
		}
	}
		
	//---Receive
	public {
		@property bool empty() {
			return socket.msgs.length == 0;
		}
		@property const(ubyte)[] front() {
			return socket.msgs[0];
		}
		void popFront() {
			msgID++;
			assert(!empty);
			socket.msgs = socket.msgs[1..$];
		}
	}
	
}


class StaticRouter {
	private immutable string path;
	
	this(string path) {
		if(!path.endsWith("/")) path ~= "/";
		this.path = path;
	}
	
	@Get(`(.*)`) get(ServerRequest req, ServerResponse res, string file) {
		file = buildNormalizedPath(this.path, file);
		if(file.exists && file.isDir)
			file = buildNormalizedPath(file,"index.html");
		if(!file.exists && file.extension is null)
			file = file.setExtension("html");
		
		if (file.startsWith("../") || file.endsWith("/..") || file == "..") {
			res.status = StatusCodes.notFound;
		}
		else if(file.exists) {
			if (file.isFile) {
				// browsers should be able to get the mime type from the content
				if (auto mime = file.extension in mimeTypes)
					res.contentType(*mime);
				res.body_ = read(file);
			}
		}
		else {
			res.status = StatusCodes.notFound;
		}
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
}




