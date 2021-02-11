require 'socket'
require_relative './memcached_manager'
require_relative './utils'

# This class represents the memcached server that will be in
# charge of managing client connections, validating and
# responding to requests.
class Server

  # Instantiating objects of this class will initialize the port, the
  # memcached @manager and a hash structure to store
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
    puts "MEMCACHED SERVER LISTENING ON PORT: #{@port}"
  end

  # This method allows accepting new connections and
  # creating a thread for each of them in order to support
  # multiple clients at the same time.
  def accept_clients
    loop do
      client_thread = Thread.start(@server.accept) do |client|
        puts "CONNECTED TO #{client}"
        @clients[client] = Thread.current
        begin
          handle_client(client)
        rescue StandardError => e
          shutdown(client)
        end
      end.join
      client_thread.join
    end
  end

  # This method allows to obtain requests from clients,
  # read them, activate the processing method and then
  # write a response.
  def handle_client(client)
    loop do
      request = client.gets
      next unless request
      response = process(request, client)
    end
  end

  # This method allows to validate and process a
  # request using the services offered by the memcached @manager.
  def process(request, client)
    commands = request.split
    action = commands.shift.upcase
    data = client.gets unless request.include? 'get'
    no_reply = commands.include?('noreply')
    if @manager.validate_request(action, commands, data)
      puts "PROCESS #{action} AT #{Time.now}"
      response = @manager.process(action, commands, data)
      client.write(response) unless no_reply
    else
      client.write(Utils::CLIENT_ERROR)
    end
  end

  # This method allows to close the connection with a client
  # and also to free the resources of a thread by terminating it.
  def shutdown(client)
    client.close
    puts "SHUTDOWN #{client}"
    @clients[client].terminate
  end
end
