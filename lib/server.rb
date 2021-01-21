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
        begin
          handle(client)
        rescue StandardError => e
          client.write("SERVER_ERROR #{e}\r\n")
        ensure
          client.close
        end
      end
    end
  end

  def handle(socket)
    request = socket.read
    response = process(request)
    socket.write(response)
  end

  def process(request)
    puts(request)
    'done'
  end
end

server = Server.new(3000)
server.start
