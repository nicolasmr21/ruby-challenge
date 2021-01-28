require 'socket'
require './memcached_manager'

class Server

  def initialize(port)
    @port = port
    @manager = MemcachedManager.new
    @clients = {}
  end

  def start
    run_server
    accept_clients
  end

  def run_server
    @server = TCPServer.new(@port)
    puts "SERVER LISTENING ON PORT: #{@port}"
  end

  def accept_clients
    loop do
      Thread.start(@server.accept) do |client|
        puts "CONNECTED TO #{client}"
        @clients[client] = Thread.current
        begin
          handle_client(client)
        rescue StandardError => e
          puts "CLOSING CONNECTION TO #{client}"
          shutdown(client)
        end
      end
    end
  end

  def handle_client(client)
    loop do
      request = client.read
      if request
        response = process(request)
        client.write(response)
      else
        shutdown(client)
      end
    end
  end

  def process(request)
    puts request
    commands, data = format_request(request)
    action = commands.shift.upcase
    if @manager.validate_request(action, commands, data)
      puts "PROCESS #{action} AT #{Time.now}"
      @manager.process(action, commands, data)
    else
      "CLIENT_ERROR THE INPUT DOES NOT CONFORM THE PROTOCOL\r\n"
    end
  end

  def format_request(request)
    lines = request.split("\n")
    [lines[0].split, lines[1]]
  end

  def shutdown(client)
    client.close
    @clients[client].terminate
  end
end

server = Server.new(3000)
server.start
