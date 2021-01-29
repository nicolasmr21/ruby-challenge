require 'socket'

# This class represents a memcached client that will allow
# users to make requests to a server following the
# established protocol.
class Client

  # When instantiating an object of this class
  # only the host and port values will be initialized.
  def initialize(host, port)
    @host = host
    @port = port
  end

  # This method allows to obtain the user entries that will be
  # used to make requests to the server.
  def start
    loop do
      command = gets.chomp
      data = gets.chomp unless command.include? 'get'
      request(command, data)
    end
  end

  # This method allows you to make a request to the server
  # and print the command response.
  def request(command, data)
    socket = TCPSocket.new(@host, @port)
    data = data.nil? ? '' : "#{data}\r\n"
    socket.write("#{command}\r\n#{data}")
    socket.close_write
    puts socket.read
  end
end
