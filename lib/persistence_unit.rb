# This class represents the persistence unit to be used
# to store the data.
class PersistenceUnit

  # When instantiating an object of this class, a hash unit is
  # created to store key-value elements.
  # It is also called the method that purges the keys.
  def initialize
    @storage = {} # "KEY" = ["DATA", "FLAGS", "EXPIRATION TIME", "BYTES", "CAS KEY", "MODIFICATION DATE"]
    start_purge_thread(1)
  end

  # This method allows to obtain the value associated to a key.
  def get(key)
    @storage[key]
  end

  # This method allows to set the value associated with a key
  def set(key, value)
    @storage[key] = value
  end

  # This method allows to know if the hash structure contains
  # a specific key.
  def exist_key(key)
    !@storage[key].nil?
  end

  # This method allows to create a thread that every x
  # seconds will activate the function to purge the keys.
  def start_purge_thread(seconds)
    Thread.new do
      loop do
        sleep(seconds)
        purge_keys
      end
    end
  end

  # This method allows to remove from the hash structure
  # the key-value elements that have already expired.
  def purge_keys
    @storage.each do |key, value|
      exptime = value[2]
      modification_date = value[5]
      diff = Time.now.to_f - modification_date.to_f
      if diff > exptime
        puts "PURGE KEY: #{key}"
        @storage.delete(key)
      end
    end
  end
end
