import {Bridge} from "/modules/Ports/Bridge.m.js";

import "/modules/UI/Slider.m.js";
import "/modules/UI/Button.m.js";
import "/modules/UI/Radar.m.js";
import "/modules/UI/RadarView.m.js";
import "/modules/UI/RadarSpawner.m.js";
import "/modules/UI/Keys.m.js";

window.ws = new WebSocket("ws://"+document.location.host+"/ws");

window.server = {
	msgID: 0,
	sentMsgID: 0,
	send: (...args) => {
		server.sentMsgID++;
		ws.send(...args);
	},
}

window.bridge = new Bridge(server);

function recvMsg(msg) {
	bridge.dispatchMsg(new Uint8Array(msg));
}

ws.addEventListener("open",e=>console.log("Open ",e));
ws.addEventListener("error",e=>console.log("Error ",e));
ws.addEventListener("message",e=>{
	server.msgID++;
	e.data.arrayBuffer().then(m=>recvMsg(m));
});
ws.addEventListener("close",e=>console.log("Close ",e));

document.body.innerHTML = `
	<ui-radar>
		<ui-radar-view port="0" />
	</ui-radar>
	<ui-slider port="0"></ui-slider>
	<ui-slider port="1"></ui-slider>
	<ui-slider port="2"></ui-slider>
	<ui-slider port="3"></ui-slider>
	<ui-slider port="4"></ui-slider>
	<ui-slider port="5"></ui-slider>
	
	<ui-wire-keys port="0" key="KeyN" negKey="KeyH"></ui-wire-keys>
	<ui-wire-keys port="1" key="KeyE" negKey="Comma"></ui-wire-keys>
	<ui-wire-keys port="2" key="KeyR" negKey="KeyW"></ui-wire-keys>
	
	<ui-ping-key port="0" key="Space"></ui-ping-key>
`;

