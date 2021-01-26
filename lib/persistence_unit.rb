class PersistenceUnit

  def initialize
    @storage = {} # "KEY" = ["DATA", "FLAGS", "EXPIRATION TIME", "BYTES", "CAS KEY", "MODIFICATION DATE"]
    start_purge_thread
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

  def start_purge_thread
    Thread.new do
      sleep(5)
      purge_keys
    end
  end

  def purge_keys
    @storage.each do |key, value|
      exptime = value[2]
      modification_date = value[5]
      diff = Time.now.to_f - modification_date.to_f
      if diff > exptime
        puts "delete #{key}"
        @storage.delete(key)
      end
    end
  end

end
