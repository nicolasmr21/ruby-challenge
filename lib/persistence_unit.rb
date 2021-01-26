class PersistenceUnit

  def initialize
    @storage = {
      '1' => ['xxx', 1, 5, 3, 1, Time.now],
      '2' => ['xxx', 1, 10, 3, 1, Time.now]
    } # "KEY" = ["DATA", "FLAGS", "EXPIRATION TIME", "BYTES", "CAS KEY", "MODIFICATION DATE"]
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
      loop do
        sleep(5)
        purge_keys
      end
    end
  end

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
