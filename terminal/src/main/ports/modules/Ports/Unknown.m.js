import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";

export
class UnknownPort extends Port {
	networkedType;
	constructor(type, typeID) {
		super(PortType.unknown, typeID);
		networkedType = type;
	}
}
portMixin_withRPC(UnknownPort);
