import {Ship} from "./Ship.m.js";

window.ws = new WebSocket("ws://"+document.location.host+"/ws");

window.server = {
	msgID: 0,
	sentMsgID: 0,
	send: (...args) => {
		server.sentMsgID++;
		ws.send(...args);
	},
}

let ship = new Ship(server);
window.ship = ship;

ws.addEventListener("open",e=>console.log("Open ",e));
ws.addEventListener("error",e=>console.log("Error ",e));
ws.addEventListener("message",e=>{
	server.msgID++;
	e.data.arrayBuffer().then(m=>ship.recvMsg(m));
});
ws.addEventListener("close",e=>console.log("Close ",e));



