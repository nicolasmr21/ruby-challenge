require 'socket'

class Server

  def initialize(port)
    @storage = { '2' => ['database', 15, 4000, 8, 0], '3' => ['databasx', 11, 6000, 8, 0] }
    @server = TCPServer.new(port)
    puts "SERVER LISTENING ON PORT: #{port}"
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
    commands, data = format_request(request)
    action = commands.shift.upcase
    puts "PROCESS #{action} AT #{Time.now}"
    case action
    when 'GET'
      get(commands[0])
    when 'GETS'
      gets(commands)
    when 'SET'
      set(commands[0], commands[1], commands[2], commands[3], data)
    when 'ADD'
      add(commands[0], commands[1], commands[2], commands[3], data)
    when 'REPLACE'
      replace(commands[0], commands[1], commands[2], commands[3], data)
    when 'APPEND'
      append(commands[0], commands[3], data)
    when 'PREPEND'
      prepend(commands[0], commands[3], data)
    else
      "ERROR\r\n"
    end
  end

  def format_request(request)
    lines = request.split("\n")
    [lines[0].split, lines[1]]
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
  end

  def set(key, flags, exptime, bytes, data)
    @storage[key] = [data, flags, exptime, bytes, 0]
    "STORED\r\n"
  end

  def add(key, flags, exptime, bytes, data)
    if @storage[key].nil?
      @storage[key] = [data, flags, exptime, bytes, 0]
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  def replace(key, flags, exptime, bytes, data)
    if !@storage[key].nil?
      @storage[key] = [data, flags, exptime, bytes, 0]
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  def append(key, bytes, data)
    item = @storage[key]
    if !item.nil?
      @storage[key] = [item[0] + data, item[1], item[2], item[3] + bytes, 0]
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  def prepend(key, bytes, data)
    item = @storage[key]
    if !item.nil?
      @storage[key] = [data + item[0], item[1], item[2], item[3] + bytes, 0]
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

end

server = Server.new(3000)
server.start
