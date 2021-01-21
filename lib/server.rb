require 'socket'

class Server
  def initialize(port)
    @storage = { '2' => ['database', 15, 4000, 8, 0], '3' => ['databasx', 11, 6000, 8, 0] }
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
    command = commands.shift.upcase
    puts "PROCESS #{command} AT #{Time.now}"
    case command
    when 'GET'
      get(commands[0])
    when 'GETS'
      gets(commands)
    when 'SET'
      set(commands[0], commands[1], commands[2], commands[3], data)
    end
  end

  def get(key)
    item = @storage[key]
    "VALUE #{key} #{item[1]} #{item[2]} #{item[3]} #{item[4]}\r\n#{item[0]}\r\nEND\r\n"
  end

  def gets(keys)
    response = ''
    keys.each do |key|
      item = @storage[key]
      response += "VALUE #{key} #{item[1]} #{item[2]} #{item[3]} #{item[4]}\r\n#{item[0]}\r\n"
    end
    response += "END\r\n"
    response
  end

  def set(key, flags, exptime, bytes, data)
    @storage[key] = [data, flags, exptime, bytes, 0]
    "STORED\r\n"
  end
end

server = Server.new(3000)
server.start
