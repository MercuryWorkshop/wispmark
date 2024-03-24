const http = require("node:http");
const wisp = require("wisp-server-node");

const httpServer = http.createServer();

httpServer.on("upgrade", (req, socket, head) => {
  wisp.routeRequest(req, socket, head);
});

httpServer.on("listening", () => {
  console.log("HTTP server listening");
});

httpServer.listen({
  port: parseInt(process.argv[2]),
});