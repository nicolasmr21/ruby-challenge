require 'socket'

class Server
  def initialize(port)
    @storage = { '2' => ['database', 15, 4000, 8, 0] }
    @server = TCPServer.new(port)
    puts "Server listening on port: #{port}"
  end

  def start
    loop do
      Thread.start(@server.accept) do |client|
        begin
          handle(client)
        rescue StandardError => e
          client.write("SERVER_ERROR #{e.message}\r\n")
        ensure
          client.close
        end
      end
    end
  end

  def handle(socket)
    request = socket.read
    response = process(request)
    socket.write(response)
  end

  def process(request)
    lines = request.split("\n")
    commands = lines[0].split
    data = lines[1]

    case commands[0].upcase
    when 'GET'
      key = commands[1]
      item = @storage[key]
      puts(key, item)
      "VALUE #{key} #{item[1]} #{item[2]} #{item[3]} #{item[4]}\r\n#{item[0]}\r\nEND\r\n"
    when 'SET'
      key = commands[1]
      flags = commands[2]
      exptime = commands[3]
      bytes = commands[4]
      noreply = commands[5]
      @storage[key] = [data, flags, exptime, bytes, 0]
      puts @storage
      "STORED\r\n"
    end
  end
end

server = Server.new(3000)
server.start
