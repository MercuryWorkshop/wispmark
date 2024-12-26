import { client } from "@mercuryworkshop/wisp-js/client";
const { ClientConnection } = client;

let server_port = parseInt(process.argv[2]);
let target_port = parseInt(process.argv[3]);
let stream_count = parseInt(process.argv[4]);

let ws_url = `ws://127.0.0.1:${server_port}/`;
let payload = new TextEncoder().encode("a".repeat(1024 * 50));
let max_buffered = 50 * 1024 * 1024;

console.log(`connecting to ${ws_url}`)
let conn = new ClientConnection(ws_url);
conn.onopen = () => {
  console.log(`connected, opening ${stream_count} streams`)
  for (let i=0; i < stream_count; i++) {
    let stream = conn.create_stream("127.0.0.1", target_port);
    
    setInterval(() => {
      if (stream.send_buffer.length < 100 && conn.ws.bufferedAmount < max_buffered) {
        for (let j = 0; j < 10; j++) {
          stream.send(payload);
        }
      }
    }, 0);
  } 
}; 