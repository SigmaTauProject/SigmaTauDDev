

let ws = new WebSocket("ws://"+document.location.host+"/ws");

ws.addEventListener("open",e=>console.log("Open ",e));
ws.addEventListener("error",e=>console.log("Error ",e));
ws.addEventListener("message",e=>{
	e.data.arrayBuffer().then(console.log);
});
ws.addEventListener("close",e=>console.log("Close ",e));
 
