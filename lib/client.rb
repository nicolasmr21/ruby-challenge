require 'socket'

class Client

  def initialize(host, port)
    @host = host
    @port = port
  end

  def start
    socket = TCPSocket.new(@host, @port)
    loop do
      command = gets.chomp
      data = gets.chomp unless command.include? 'get'
      request(command, data)
    end
  end

  def request(command, data)
    socket.write("#{command}\r\n#{data}\r\n")
    socket.close_write
    response = socket.read
    puts response
  end

end

client = Client.new('localhost', 3000)
client.start
