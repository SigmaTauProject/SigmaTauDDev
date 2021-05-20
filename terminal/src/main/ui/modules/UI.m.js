 

export
class UIWithPort extends HTMLElement {
	port = null;
	portID = 0;
	
	constructor(...args) {
		super(...args);
		this.portID = +this.getAttribute("port") || 0;
	}
	
	attachPort(port, last=null) {
		console.log("attachPort", port);
		this.port = port;
		if (last)
			last.unlisten(this.onPortChanged.bind(this));
		if (port)
			port.listen(this.onPortChanged.bind(this));
	}
	
	connectedCallback() {
		console.log("connected");
		console.assert(this.constructor.portType !== undefined, "UIWithPort inheritors must define static portType member.");
		bridge.attachUI(this.constructor.portType, this.portID, this.attachPort.bind(this));
	}
	disconnectedCallback() {
		console.log("disconnected");
		bridge.attachUI(this.constructor.portType, this.portID, this.attachPort.bind(this));
	}
}
