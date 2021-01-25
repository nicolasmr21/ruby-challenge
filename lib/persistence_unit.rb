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

  def exist(key)
    !@storage[key].nil?
  end

end
