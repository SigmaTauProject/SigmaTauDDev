import {mixinRPC} from "/modules/StructuredRPC.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export
const PortType = {
	bridge	: 0,
	wire	: 1,
	wireIn	: 2,
	wireOut	: 3,
	radar	: 4,
	unknown	: -1,
}

export
const Src = {
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
