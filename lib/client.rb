require 'socket'

class Client
  def initialize(host, port)
    @socket = TCPSocket.new(host, port)
  end

  def start
    loop do
      command = gets
      request(command)
    end
  end

  def request(string)
    @socket.write(string)
    @socket.read
  end
end

client = Client.new('localhost', 3000)
client.start
