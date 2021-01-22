class PersistenceUnit

  def initialize
    @storage = { '2' => ['database', 15, 4000, 8, 0] }
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
