require 'socket'

class Client

  def initialize(host, port)
    @host = host
    @port = port
  end

  def start
    loop do
      command = gets.chomp
      data = gets.chomp unless command.include? 'get'
      request(command, data)
    end
  end

  def request(command, data)
    socket = TCPSocket.new(@host, @port)
    data = data.nil? ? '' : "#{data}\r\n"
    socket.write("#{command}\r\n#{data}")
    socket.close_write
    puts socket.read
  end

end

client = Client.new('localhost', 3000)
client.start
