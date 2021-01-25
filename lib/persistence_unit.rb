class PersistenceUnit

  def initialize
    @storage = { '2' => ['database', 15, 5000, 8, 0, Time.now] }
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
