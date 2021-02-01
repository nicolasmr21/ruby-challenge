require_relative './persistence_unit'
require 'securerandom'

# This class represents the memcached manager that is in
# charge of processing the commands that arrive as
# requests to the server.
class MemcachedManager

  # When an object of this class is instantiated, an instance of
  # the persistence unit is created in order to store the data.
  def initialize
    @storage = PersistenceUnit.new
  end

  # This method allows to find the associated logic specific to
  # each action.
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

  # This method allows to validate that the structure of each
  # command complies with the memcached protocol.
  def validate_request(action, commands, data)
    if %w[GET GETS].include? action
      has_keys = !commands.empty?
      valid_size = action == 'GET' ? commands.size == 1 : commands.size >= 1
      has_keys && valid_size
    elsif %w[SET ADD REPLACE APPEND PREPEND].include? action
      key, flags, exptime, bytes = commands
      puts(key, flags, exptime, bytes)
      !key.nil? && !data.nil? && (!flags.nil? && flags.to_i) && (!exptime.nil? && exptime.to_i) && (!bytes.nil? && bytes.to_i)
    elsif action == 'CAS'
      key, flags, exptime, bytes, cas = commands
      !key.nil? && !data.nil? && (!flags.nil? && flags.to_i) && (!exptime.nil? && exptime.to_i) && !cas.nil?
    else
      false
    end
  end

  # get method is used to get the value stored at key.
  # If the key does not exist in Memcached, then it returns nothing.
  def get(key)
    if @storage.exist_key(key)
      item = @storage.get(key)
      "VALUE #{key} #{item[1]} #{item[2]} #{item[3]} #{item[4]}\r\n#{item[0]}\r\nEND\r\n"
    else
      "END\r\n"
    end
  end

  # gets method is used to get the values stored at a set of keys.
  # If a key does not exist in Memcached, then the value of this key returns nothing.
  def gets(keys)
    response = ''
    keys.each do |key|
      if @storage.exist_key(key)
        item = @storage.get(key)
        response += "VALUE #{key} #{item[1]} #{item[2]} #{item[3]} #{item[4]}\r\n#{item[0]}\r\n"
      end
    end
    response += "END\r\n"
  end

  # set method is used to set a new value to a new or existing key.
  def set(key, flags, exptime, bytes, data)
    @storage.set(key, [data[0...bytes], flags, exptime, bytes, SecureRandom.hex(16), Time.now])
    "STORED\r\n"
  end

  # add method is used to set a value to a new key.
  # If the key already exists, then it gives the output NOT_STORED.
  def add(key, flags, exptime, bytes, data)
    if !@storage.exist_key(key)
      @storage.set(key, [data[0...bytes], flags, exptime, bytes, SecureRandom.hex(16), Time.now])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  # replace method is used to replace the value of an existing key.
  # If the key does not exist, then it gives the output NOT_STORED.
  def replace(key, flags, exptime, bytes, data)
    if @storage.exist_key(key)
      @storage.set(key, [data[0...bytes], flags, exptime, bytes, SecureRandom.hex(16), Time.now])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  # append method is used to add some data in an existing key.
  # The data is stored after the existing data of the key.
  def append(key, bytes, data)
    item = @storage.get(key)
    if !item.nil?
      @storage.set(key, [item[0] + data[0...bytes], item[1], item[2], item[3] + bytes, item[4], item[5]])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  # prepend command is used to add some data in an existing key.
  # The data is stored before the existing data of the key.
  def prepend(key, bytes, data)
    item = @storage.get(key)
    if !item.nil?
      @storage.set(key, [data[0...bytes] + item[0], item[1], item[2], item[3] + bytes, item[4], item[5]])
      "STORED\r\n"
    else
      "NOT_STORED\r\n"
    end
  end

  # cas command is used to set the data if it is not updated since last fetch.
  # If the key does not exist in Memcached, then it returns NOT_FOUND.
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
