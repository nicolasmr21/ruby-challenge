class PersistenceUnit

  def initialize
    @storage = {} # "KEY" = ["DATA", "FLAGS", "EXPIRATION TIME", "BYTES", "CAS KEY", "MODIFICATION DATE"]
  end

  def get(key)
    @storage[key]
  end

  def set(key, value)
    @storage[key] = value
  end

  def exist_key(key)
    !@storage[key].nil?
  end

  def exist_keys(keys)
    keys.each do |key|
      next unless @storage[key].nil?
      return false
    end
    true
  end

end
