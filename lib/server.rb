require 'socket'

class Server
  def initialize(port)
    @storage = {}
    @server = TCPServer.new(port)
    puts "Server listening on port: #{port}"
  end

  def start
    loop do
      Thread.start(@server.accept) do |client|
        handle(client)
        client.close
      end
    end
  end

  def handle(socket)
    request = socket.read
    response = process(request)
    socket.write(response)
  end

  def process(request)
    command, key, value = request.split
    puts(command, key, value)
    'done'
  end
end

server = Server.new(3000)
server.start
