require_relative '../lib/persistence_unit'

describe PersistenceUnit do

  describe '#get' do
    storage = PersistenceUnit.new
    item = ['testdata', 12, 100, 8, 'c0ceb73bd7d652b', Time.now]
    storage.set('1', item)
    it 'should return nil if key does not exist' do
      expect(storage.get('2')).to be_nil
      expect(storage.get('')).to be_nil
      expect(storage.get(item)).to be_nil
    end
    it 'should return item if key exist' do
      expect(storage.get('1')).to eq(item)
    end
  end

  describe '#set' do
    storage = PersistenceUnit.new
    itemx = ['testdata', 12, 100, 8, 'c0ceb73bd7d652b', Time.now]
    itemy = ['setdata', 12, 100, 7, 'c0ceb73bd7d652b', Time.now]
    it 'should set a new item' do
      expect(storage.get('1')).to be_nil
      storage.set('1', itemx)
      expect(storage.get('1')).to eq(itemx)
    end
    it 'should replace a item if exist' do
      storage.set('1', itemx)
      expect(storage.get('1')).to eq(itemx)
      storage.set('1', itemy)
      expect(storage.get('1')).to eq(itemy)
    end
  end

  describe '#exist_key' do
    storage = PersistenceUnit.new
    item = ['testdata', 12, 100, 8, 'c0ceb73bd7d652b', Time.now]
    storage.set('1', item)
    it 'should return false if key does not exist' do
      expect(storage.exist_key('2')).to be_falsey
    end
    it 'should return true if key exist' do
      expect(storage.exist_key('1')).to be_truthy
    end
  end

  describe '#purge_keys' do
    storage = PersistenceUnit.new
    itemx = ['testdata', 12, 2, 8, 'c0ceb73bd7d652b', Time.now]
    itemy = ['setdata', 12, 8, 7, 'c0ceb73bd7d652b', Time.now]
    storage.set('1', itemx)
    storage.set('2', itemy)
    it 'should remove expired keys' do
      expect(storage.exist_key('1')).to be_truthy
      sleep(3)
      expect(storage.exist_key('1')).to be_falsey
    end
    it 'should keep items if is there is not expired keys' do
      sleep(3)
      expect(storage.exist_key('2')).to be_truthy
      sleep(3)
      expect(storage.exist_key('2')).to be_falsey
    end
  end

end
