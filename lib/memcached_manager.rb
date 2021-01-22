require './persistence_unit'

class MemcachedManager

  def initialize
    @storage = PersistenceUnit.new
  end

  def process(action, commands, data)
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

  def get(key)
    item = @storage.get(key)
    "VALUE #{key} #{item[1]} #{item[2]} #{item[3]} #{item[4]}\r\n#{item[0]}\r\nEND\r\n"
  end

  def gets(keys)
    response = ''
    keys.each do |key|
      item = @storage.get(key)
      response += "VALUE #{key} #{item[1]} #{item[2]} #{item[3]} #{item[4]}\r\n#{item[0]}\r\n"
    end
    response += "END\r\n"
  end

  def set(key, flags, exptime, bytes, data)
    @storage.set(key, [data, flags, exptime, bytes, 0])
    "STORED\r\n"
  end

  def add(key, flags, exptime, bytes, data)
    if !@storage.exist(key)
      @storage.set(key, [data, flags, exptime, bytes, 0])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  def replace(key, flags, exptime, bytes, data)
    if @storage.exist(key)
      @storage.set(key, [data, flags, exptime, bytes, 0])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  def append(key, bytes, data)
    item = @storage.get(key)
    if !item.nil?
      @storage.set(key, [item[0] + data, item[1], item[2], item[3] + bytes, 0])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  def prepend(key, bytes, data)
    item = @storage.get(key)
    if !item.nil?
      @storage.set(key, [data + item[0], item[1], item[2], item[3] + bytes, 0])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end
end
