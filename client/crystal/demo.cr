require "./git/client.cr"

server_port = ARGV[0].to_i
target_port = ARGV[1].to_i
stream_count = ARGV[2].to_i

ws_url = "ws://127.0.0.1:#{server_port}/"
payload = ("a" * (1024 * 50)).to_slice
max_buffered = 50 * 1024 * 1024

puts "connecting to #{ws_url}"
conn = Wisp.get_connection(ws_url)

# Set up connection event handlers
conn.add_listener("open") do |_event|
  puts "connected, opening #{stream_count} streams"

  stream_count.times do
    stream = conn.create_stream("127.0.0.1", target_port)
    
    spawn do
      loop do
        if stream.buffered_amount < 100
          10.times do
            stream.send(payload)
          end
        end
        sleep(0)
      end
    end
  end

end

sleep
