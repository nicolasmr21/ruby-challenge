require 'socket'
require_relative './memcached_manager'

# This class represents the memcached server that will be in
# charge of managing client connections, validating and
# responding to requests.
class Server

  # Instantiating objects of this class will initialize the port, the
  # memcached manager and a hash structure to store
  # information about the clients.
  def initialize(port)
    @port = port
    @manager = MemcachedManager.new
    @clients = {}
  end

  # This method allows you to activate the functions in charge
  # of initializing the server and start accepting clients.
  def start
    run_server
    accept_clients
  end

  # This method allows to instantiate the server
  # using the TCPServer class provided by the core.
  def run_server
    @server = TCPServer.new(@port)
    puts "SERVER LISTENING ON PORT: #{@port}"
  end

  # This method allows accepting new connections and
  # creating a thread for each of them in order to support
  # multiple clients at the same time.
  def accept_clients
    loop do
      Thread.start(@server.accept) do |client|
        @clients[client] = Thread.current
        begin
          handle_client(client)
        rescue StandardError => e
          shutdown(client)
        end
      end
    end
  end

  # This method allows to obtain requests from clients,
  # read them, activate the processing method and then
  # write a response.
  def handle_client(client)
    loop do
      request = client.read
      if request
        response = process(request)
        client.write(response)
      else
        shutdown(client)
      end
    end
  end

  # This method allows to validate and process a
  # request using the services offered by the memcached manager.
  def process(request)
    commands, data = format_request(request)
    action = commands.shift.upcase
    if @manager.validate_request(action, commands, data)
      puts "PROCESS #{action} AT #{Time.now}"
      @manager.process(action, commands, data)
    else
      "CLIENT_ERROR THE INPUT DOES NOT CONFORM THE PROTOCOL\r\n"
    end
  end

  # This method allows to format a request
  # in order to separate the command and the data in a
  # form that the memcached administrator can handle.
  def format_request(request)
    lines = request.split("\n")
    [lines[0].split, lines[1]]
  end

  # This method allows to close the connection with a client
  # and also to free the resources of a thread by terminating it.
  def shutdown(client)
    client.close
    @clients[client].terminate
  end
end
