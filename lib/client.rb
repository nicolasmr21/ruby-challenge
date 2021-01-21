require 'socket'

class Client
  def initialize(host, port)
    @host = host
    @port = port
  end

  def start
    loop do
      command = gets
      data = gets unless command.include? 'get'
      request(command, data)
    end
  end

  def request(command, data)
    socket = TCPSocket.new(@host, @port)
    socket.write("#{command}\r\n#{data}\r\n")
    socket.close_write
    response = socket.read
    puts response
  end
end

client = Client.new('localhost', 3000)
client.start
