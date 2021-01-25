require './persistence_unit'
require 'securerandom'

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
      set(commands[0], commands[1].to_i, commands[2].to_i, commands[3].to_i, data)
    when 'ADD'
      add(commands[0], commands[1].to_i, commands[2].to_i, commands[3].to_i, data)
    when 'REPLACE'
      replace(commands[0], commands[1].to_i, commands[2].to_i, commands[3].to_i, data)
    when 'APPEND'
      append(commands[0], commands[3].to_i, data)
    when 'PREPEND'
      prepend(commands[0], commands[3].to_i, data)
    when 'CAS'
      cas(commands[0], commands[1].to_i, commands[2].to_i, commands[3].to_i, commands[4], data)
    else
      "ERROR\r\n"
    end
  end

  def validate_request(action, commands, data)
    if %w[GET GETS].include? action
      has_keys = !commands.empty?
      valid_size = action == 'GET' ? commands.size == 1 : commands.size >= 1
      has_keys && valid_size
    elsif %w[SET ADD REPLACE APPEND PREPEND].include? action
      key, flags, exptime, bytes = commands
      !key.nil? && (!flags.nil? && flags.to_i) && (!exptime.nil? && exptime.to_i) && (!bytes.nil? && bytes.to_i)
    elsif action == 'CAS'
      key, flags, exptime, bytes, cas = commands
      !key.nil? && (!flags.nil? && flags.to_i) && (!exptime.nil? && exptime.to_i) && !cas.nil?
    else
      false
    end
  end

  def get(key)
    if @storage.exist_key(key)
      item = @storage.get(key)
      "VALUE #{key} #{item[1]} #{item[2]} #{item[3]} #{item[4]}\r\n#{item[0]}\r\nEND\r\n"
    else
      'CLIENT_ERROR KEY DOES NOT EXIST'
    end
  end

  def gets(keys)
    if @storage.exist_keys(keys)
      response = ''
      keys.each do |key|
        item = @storage.get(key)
        response += "VALUE #{key} #{item[1]} #{item[2]} #{item[3]} #{item[4]}\r\n#{item[0]}\r\n"
      end
      response += "END\r\n"
    else
      'CLIENT_ERROR ONE OF THE SPECIFIED KEYS DOES NOT EXIST'
    end
  end

  def set(key, flags, exptime, bytes, data)
    @storage.set(key, [data[0...bytes], flags, exptime, bytes, SecureRandom.hex(16), Time.now])
    "STORED\r\n"
  end

  def add(key, flags, exptime, bytes, data)
    if !@storage.exist_key(key)
      @storage.set(key, [data[0...bytes], flags, exptime, bytes, SecureRandom.hex(16), Time.now])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  def replace(key, flags, exptime, bytes, data)
    if @storage.exist_key(key)
      @storage.set(key, [data[0...bytes], flags, exptime, bytes, SecureRandom.hex(16), Time.now])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  def append(key, bytes, data)
    item = @storage.get(key)
    if !item.nil?
      @storage.set(key, [item[0] + data[0...bytes], item[1], item[2], item[3] + bytes, item[4], item[5]])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  def prepend(key, bytes, data)
    item = @storage.get(key)
    if !item.nil?
      @storage.set(key, [data[0...bytes] + item[0], item[1], item[2], item[3] + bytes, item[4], item[5]])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  def cas(key, flags, exptime, bytes, cas, data)
    item = @storage.get(key)
    if !item.nil?
      if cas == item[4]
        set(key, flags, exptime, bytes, data)
      else
        "EXISTS \r\n"
      end
    else
      "NOT_FOUND\r\n"
    end
  end
end
