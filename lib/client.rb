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
    @socket = TCPSocket.new(@host, @port)
    @request = nil
    @response = nil
  end

  # This method allows to obtain the user entries that will be
  # used to make requests to the server.
  def start
    puts 'MEMCACHED CLIENT STARTED, TYPE YOUR COMMAND'
    request
    listen
    @request.join
    @response.join
  end

  # This method allows you to make a request to the server
  def request
    @request = Thread.new do
      loop do
        command = gets.chomp
        data = gets.chomp unless command.include? 'get'
        data = data.nil? ? '' : "#{data}\r\n"
        @socket.write("#{command}\r\n#{data}")
      end
    end
  end

  # This method allows client to listen server responses
  def listen
    @response = Thread.new do
      loop do
        puts @socket.gets
      end
    end
  end
end
