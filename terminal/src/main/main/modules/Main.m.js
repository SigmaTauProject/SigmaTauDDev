import {Ship} from "./Ship.m.js";

let ws = new WebSocket("ws://"+document.location.host+"/ws");
window.ws = ws;

let ship = new Ship(ws);
window.ship = ship;

ws.addEventListener("open",e=>console.log("Open ",e));
ws.addEventListener("error",e=>console.log("Error ",e));
ws.addEventListener("message",e=>{
	e.data.arrayBuffer().then(m=>ship.recvMsg(m));
});
ws.addEventListener("close",e=>console.log("Close ",e));



