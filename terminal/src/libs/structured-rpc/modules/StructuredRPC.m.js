import {Serializer, SerialType, NoLength} from "/modules/Serial.m.js";

export
function mixinRPCReceive(Cls, config={}) {
	if (config.serializer == undefined)
		config.serializer = new Serializer();
	if (config.idType == undefined)
		config.idType = SerialType.uint8;
	
	let rpcByID = [];
	
	let lastID = -1;
	for (let rpc of Object.keys(Cls).filter(k=>k.startsWith("rpc_")).map(k=>k.slice("rpc_".length))) {
		let id;
		let params;
		{
			let data = Cls["rpc_"+rpc];
			if (data.length && typeof data[0] == "number") {
				id = data[0];
			}
			else {
				id = lastID+1;
			}
			lastID = id;
			rpcByID[id] = rpc;
		}
	}
	
	Object.defineProperty(Cls.prototype, "rpcRecv", {value:
		function(bytes, src) {
			let id = config.serializer.deserialize(config.idType, bytes, b=>bytes=b);
			let rpc = rpcByID[id];
			let params;
			
			let data = Cls["rpc_"+rpc];
			if (data.length && typeof data[0] == "number")
				params = data.slice(1);
			else
				params = data;
			
			let args = [];
			for (let i=0; i<params.length; i++) {
				let attributes = i == params.length-1 ? [NoLength()] : [];
				let type;
				if (params[i].constructor == Array) {
					type = params[i][0];
					attributes.push(...params[i].slice(1));
				}
				else {
					type = params[i];
				}
				args.push(config.serializer.subserializer(...attributes).deserialize(type, bytes, b=>bytes=b));
			}
			this[rpc](...args, ...(src==undefined?[]:[src]));
		}
	});
}


export
function mixinRPCSendTo(Cls, To, config={}) {
	if (config.serializer == undefined)
		config.serializer = new Serializer();
	if (config.idType == undefined)
		config.idType = SerialType.uint8;
	let rpcByID = [];
	
	let lastID = -1;
	for (let rpc of Object.keys(To).filter(k=>k.startsWith("rpc_")).map(k=>k.slice("rpc_".length))) {
		let id;
		let params;
		{
			let data = To["rpc_"+rpc];
			if (data.length && typeof data[0] == "number") {
				id = data[0];
				params = data.slice(1);
			}
			else {
				id = lastID+1;
				params = data;
			}
			lastID = id;
			rpcByID[id] = rpc;
		}
		Object.defineProperty(Cls.prototype, rpc+"_send", {value:
			function(...args) {
				console.assert(args.length == params.length, "Incorrect number of arguments given, expected: "+params.length+" got: "+args.length+".");
				let bytes = config.serializer.serialize(config.idType, id);
				for (let i=0; i<params.length; i++) {
					let attributes = i == params.length-1 ? [NoLength()] : [];
					let type;
					if (params[i].constructor == Array) {
						type = params[i][0];
						attributes.push(...params[i].slice(1));
					}
					else {
						type = params[i];
					}
					bytes = new Uint8Array([...bytes, ...config.serializer.subserializer(attributes).serialize(type, args[i])]);
				}
				this.rpcSend(bytes);
			}
		});
	}
}

