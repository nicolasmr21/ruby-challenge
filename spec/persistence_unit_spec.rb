require_relative '../lib/persistence_unit'

describe PersistenceUnit do

  before(:context) do
    @storage = PersistenceUnit.new
  end

  context '#get' do
    before(:all) do
      @item = ['testdata', 12, 100, 8, 'c0ceb73bd7d652b', Time.now]
      @storage.set('1', @item)
    end
    it 'should return nil if key does not exist' do
      expect(@storage.get('2')).to be_nil
      expect(@storage.get('')).to be_nil
    end
    it 'should return item if key exist' do
      expect(@storage.get('1')).to eq(@item)
    end
  end

  context '#set' do
    before(:all) do
      @itemx = ['testdata', 12, 100, 8, 'c0ceb73bd7d652b', Time.now]
      @itemy = ['setdata', 12, 100, 7, 'c0ceb73bd7d652b', Time.now]
    end
    it 'should set a new item' do
      @storage.set('1', @itemx)
      expect(@storage.get('1')).to eq(@itemx)
    end
    it 'should replace a item if exist' do
      @storage.set('1', @itemx)
      @storage.set('1', @itemy)
      expect(@storage.get('1')).to eq(@itemy)
    end
  end

  context '#exist_key' do
    before(:all) do
      @item = ['testdata', 12, 100, 8, 'c0ceb73bd7d652b', Time.now]
      @storage.set('1', @item)
    end
    it 'should return false if key does not exist' do
      expect(@storage.exist_key('2')).to be_falsey
    end
    it 'should return true if key exist' do
      expect(@storage.exist_key('1')).to be_truthy
    end
  end

  context '#purge_keys' do
    before(:all) do
      itemx = ['testdata', 12, 2, 8, 'c0ceb73bd7d652b', Time.now]
      itemy = ['setdata', 12, 8, 7, 'c0ceb73bd7d652b', Time.now]
      @storage.set('1', itemx)
      @storage.set('2', itemy)
    end
    it 'should remove expired keys' do
      expect(@storage.key_is_expired('1')).to be_falsey
      sleep(3)
      expect(@storage.key_is_expired('1')).to be_truthy
      @storage.purge_key('1')
      expect(@storage.exist_key('1')).to be_falsey
    end
    it 'should keep items if is there is not expired keys' do
      sleep(3)
      expect(@storage.key_is_expired('2')).to be_falsey
      sleep(3)
      expect(@storage.key_is_expired('2')).to be_truthy
    end
  end
end
