# This class represents the persistence unit to be used
# to store the data.
class PersistenceUnit

  # When instantiating an object of this class, a hash unit is
  # created to store key-value elements.
  # It is also called the method that purges the keys.
  def initialize
    @storage = Hash.new # "KEY" = ["DATA", "FLAGS", "EXPIRATION TIME", "BYTES", "CAS KEY", "MODIFICATION DATE"]
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
    @storage.key?(key)
  end

  # This method allows to know if a key is expired
  def key_is_expired(key)
    value = @storage[key]
    exptime = value[2]
    modification_date = value[5]
    diff = Time.now.to_f - modification_date.to_f
    diff > exptime
  end

  # This method allows to remove from the hash structure
  # the a key-value element.
  def purge_key(key)
    puts "PURGE KEY: #{key}"
    @storage.delete(key)
  end
end
