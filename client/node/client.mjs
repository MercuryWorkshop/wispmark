import { WispConnection } from "@mercuryworkshop/wisp-client-js";

let server_port = parseInt(process.argv[2]);
let target_port = parseInt(process.argv[3]);

let ws_url = `ws://127.0.0.1:${server_port}/`;
let payload = new TextEncoder().encode("a".repeat(1024));

let conn = new WispConnection(ws_url);
conn.addEventListener("open", () => {
  for (let i=0; i<100; i++) {
    let stream = conn.create_stream("127.0.0.1", target_port);
    stream.addEventListener("message", (event) => {
      stream.send(payload);
    });
    stream.send(payload);
  }
});
