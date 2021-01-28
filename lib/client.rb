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
      request(command, data, socket)
    end
  end

  def request(command, data, socket)
    data = data.nil? ? '' : "#{data}\r\n"
    socket.write("#{command}\r\n#{data}")
    response = socket.read
    puts response
  end

end

client = Client.new('localhost', 3000)
client.start
