import {mixinRPC} from "/modules/StructuredRPC.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export
var PortType = {
	bridge	: 0,
	wireOut	: 1,
	wireIn	: 2,
	radar	: 3,
}

export
var Src = {
	server	: 1	,
	self	: 2	,
};

export
class Port {
	type;
	id;
	server;
	
	constructor(type) {
		this.type = type;
	}
	safeCast(toType) {
		if (toType==this.type)
			return this;
		else
			return null;
	}
	
	rpcSend(data) {
		data = new Uint8Array([this.id,...data]);
		this.server.send(data);
	}
	rpcRecv() {
		console.assert(false, "Abstract, Unimplemented");
	}
}

export
function portMixin_withRPC(Cls) {
	mixinRPC(Cls, {serializer:new Serializer(LengthType(SerialType.uint8))});
}
