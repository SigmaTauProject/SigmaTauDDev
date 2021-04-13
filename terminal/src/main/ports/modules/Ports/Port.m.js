import {mixinRPCSendTo, mixinRPCReceive} from "/modules/StructuredRPC.m.js";
import {Serializer, SerialType, NoLength, LengthType} from "/modules/Serial.m.js";

export
const PortType = {
	bridge	: 0,
	wire	: 1,
	////wireIn	: 2,
	////wireOut	: 3,
	pingOut	: 4,
	radar	: 5,
	spawner	: 6,
	unknown	: -1,
}

export
const Src = {
	server	: Symbol("SrcServer")	,
	self	: Symbol("SrcSelf")	,
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

var serializer = new Serializer(LengthType(SerialType.uint8));

export
function portMixin_withRPC(Cls, To=null) {
	if (To == null)
		To = Cls;
	mixinRPCSendTo(Cls, To, {serializer:serializer});
	mixinRPCReceive(Cls, {serializer:serializer});
}
