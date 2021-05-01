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
class NullPort {
	uis = [];
	constructor(...uis) {
		if (uis.length) {
			console.assert(this.constructor == NullPort);
			this.attachUI(...uis);
		}
	}
	attachUI(...uis) {
		this.uis.push(...uis);
		if (this.constructor!=NullPort)
			for (let ui of uis)
				ui(this);
	}
	unattachUI(...uis) {
		for (let ui of uis) {
			let i = this.uis.indexOf(ui);
			console.assert(i != -1);
			this.uis.splice(i,1);
			if (this.constructor != NullPort)
				ui(null, this);
		}
	}
}

export
class Port extends NullPort {
	type;
	id;
	typeID;
	server;
	
	constructor(type, typeID) {
		super();
		this.type = type;
		this.typeID = typeID;
	}
	destory() {
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
