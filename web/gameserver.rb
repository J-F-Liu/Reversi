# require 'websocket-eventmachine-server'

# EM.run do

#   WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => 8080) do |ws|
#     ws.onopen do
#       puts "Client connected"
#     end

#     ws.onmessage do |msg, type|
#       puts "Received message: #{msg}"
#       ws.send msg, :type => type
#     end

#     ws.onclose do
#       puts "Client disconnected"
#     end
#   end

# end

require 'rubame'
require 'json'

server = Rubame::Server.new("0.0.0.0", 9223)

players = {}
parties = {}

waiting_player = nil

while true
  server.run do |client|
    client.onopen do
    	id = client.object_id
      puts "client open #{id}"
  	  players[id] = client
	  	if waiting_player != nil and waiting_player != id
	  		parties[waiting_player] = id
	  		parties[id] = waiting_player
	  		players[waiting_player].send '{"action": "open"}'
	  		client.send '{"action": "open"}'
	  		waiting_player = nil
	  	else
	  		waiting_player = id
	    end
    end
    client.onmessage do |mess|
      puts "message received: #{mess}"
      if mess == "connect reversi"
      else
    	  id = client.object_id
	      if parties.has_key? id
	      	players[parties[id]].send mess
	      end
	    end
    end
    client.onclose do
    	id = client.object_id
      puts "client closed #{id}"
      mate = parties[id]
      if mate != nil
		    players[mate].send '{"action": "close"}'
	      parties.delete(mate)
	      parties.delete(id)
		  end
	    players.delete(id)
      if waiting_player == id
	  		waiting_player = nil
	    end
    end
  end
end