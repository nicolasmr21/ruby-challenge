require 'socket'
require './memcached_manager'

class Server

  def initialize(port)
    @storage = { '2' => ['database', 15, 4000, 8, 0] }
    @server = TCPServer.new(port)
    @descriptors = [@server]
    @manager = MemcachedManager.new
    puts "SERVER LISTENING ON PORT: #{port}"
  end

  def start
    loop do
      res = select(@descriptors, nil, nil, nil)
      next if res.nil?
      res[0].each do |socket|
        if socket == @server
          accept_new_connection
        elsif socket.eof?
          socket.close
          @descriptors.delete(socket)
        else
          handle_client(socket)
        end
      end
    end
  end

  def accept_new_connection
    client = @server.accept
    @descriptors.push(client)
  end

  def handle_client(socket)
    request = socket.read
    response = process(request)
    socket.write(response)
  end

  def process(request)
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
end

server = Server.new(3000)
server.start
