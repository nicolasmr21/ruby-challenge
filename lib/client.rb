require 'socket'

class Client
  def initialize(host, port)
    @host = host
    @port = port
  end

  def start
    loop do
      command = gets
      request(command)
    end
  end

  def request(string)
    socket = TCPSocket.new(@host, @port)
    socket.write(string)
    socket.close_write
    response = socket.read
    puts response
    socket.close
  end
end

client = Client.new('localhost', 3000)
client.start
