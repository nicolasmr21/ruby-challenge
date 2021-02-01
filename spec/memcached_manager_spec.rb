require_relative '../lib/memcached_manager'

describe MemcachedManager do

  manager = MemcachedManager.new

  describe '#validate_request' do
    it 'should return true if is valid' do
      expect(manager.validate_request('GET', %w[1], nil)).to be_truthy
      expect(manager.validate_request('GETS', %w[1 2], nil)).to be_truthy
      expect(manager.validate_request('SET', %w[1 23 5000 7], 'newdata')).to be_truthy
      expect(manager.validate_request('ADD', %w[1 23 5000 7], 'newdata')).to be_truthy
      expect(manager.validate_request('REPLACE', %w[1 23 5000 7], 'newdata')).to be_truthy
      expect(manager.validate_request('APPEND', %w[1 23 5000 7], 'newdata')).to be_truthy
      expect(manager.validate_request('PREPEND', %w[1 23 5000 7], 'newdata')).to be_truthy
      expect(manager.validate_request('CAS', %w[1 23 5000 7 c0ceb73], 'newdata')).to be_truthy
    end
    it 'should return false if is not valid' do
      expect(manager.validate_request('GET', '', nil)).to be_falsey
      expect(manager.validate_request('GET', %w[1 2], nil)).to be_falsey
      expect(manager.validate_request('GETS', '', nil)).to be_falsey
      expect(manager.validate_request('SET', %w[1 23 5000], 'newdata')).to be_falsey
      expect(manager.validate_request('SET', %w[1 23 5000], nil)).to be_falsey
      expect(manager.validate_request('ADD', %w[1 5000], 'newdata')).to be_falsey
      expect(manager.validate_request('REPLACE', %w[1], 'newdata')).to be_falsey
      expect(manager.validate_request('APPEND', '', 'newdata')).to be_falsey
      expect(manager.validate_request('PREPEND', %w[1 23 5000 7 25], 'newdata')).to be_falsey
      expect(manager.validate_request('CAS', %w[1 23 5000 c0ceb73], 'newdata')).to be_falsey
      expect(manager.validate_request('CAS', %w[1 23 5000 7 c0ceb73], nil)).to be_falsey
      expect(manager.validate_request('CAS', '', 'newdata')).to be_falsey
      expect(manager.validate_request('CAS', '', '')).to be_falsey

    end
  end

  describe '#get' do

  end

  describe '#gets' do

  end

  describe '#set' do

  end

  describe '#add' do

  end

  describe '#replace' do

  end

  describe '#append' do

  end

  describe '#prepend' do

  end

  describe '#cas' do

  end
end
