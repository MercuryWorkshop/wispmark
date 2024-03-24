import { WispConnection } from "@mercuryworkshop/wisp-client-js";

let server_port = parseInt(process.argv[2]);
let target_port = parseInt(process.argv[3]);
let stream_count = parseInt(process.argv[4]);

let ws_url = `ws://127.0.0.1:${server_port}/`;
let payload = new TextEncoder().encode("a".repeat(1024 * 50));

let conn = new WispConnection(ws_url);
conn.addEventListener("open", () => {
  for (let i=0; i<stream_count; i++) {
    let stream = conn.create_stream("127.0.0.1", target_port);
    setInterval(() => {
      if (stream.send_buffer.length < 100) {
        stream.send(payload);
      }
    }, 0);
  } 
}); 