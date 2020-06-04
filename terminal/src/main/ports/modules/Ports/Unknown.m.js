import {Port, PortType, Src, portMixin_withRPC} from "./Port.m.js";

export
class UnknownPort extends Port {
	constructor() {
		super(PortType.unknown);
	}
}
portMixin_withRPC(UnknownPort);
