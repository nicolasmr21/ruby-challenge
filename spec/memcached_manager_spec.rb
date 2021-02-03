require_relative '../lib/memcached_manager'

describe MemcachedManager do

  manager = MemcachedManager.new
  manager.set('1', 12, 2000, 13, 'test object x')
  manager.set('2', 10, 3000, 13, 'test object y')

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
      expect(manager.validate_request('PUT', nil, nil)).to be_falsey
    end
  end

  describe '#get' do
    it 'should return a item if it exists' do
      expect(manager.get('1')).to be_an_include 'VALUE 1 12 2000 13'
      expect(manager.get('1')).to be_an_include 'test object x'
      expect(manager.get('1')).to be_an_include "END\r\n"
    end
    it 'should return nothing if it does not exist' do
      expect(manager.get('3')).not_to be_an_include 'VALUE'
      expect(manager.get('3')).to be_an_include "END\r\n"
      expect(manager.get('')).not_to be_an_include 'VALUE'
      expect(manager.get('')).to be_an_include "END\r\n"
    end
  end

  describe '#gets' do
    it 'should return a set of item if all of they exist' do
      expect(manager.gets(%w[1 2])).to be_an_include 'VALUE 1 12 2000 13'
      expect(manager.gets(%w[1 2])).to be_an_include 'test object x'
      expect(manager.gets(%w[1 2])).to be_an_include 'VALUE 2 10 3000 13'
      expect(manager.gets(%w[1 2])).to be_an_include 'test object y'
      expect(manager.gets(%w[1 2])).to be_an_include "END\r\n"
    end
    it 'should return nothing if a item doesnt exist' do
      expect(manager.gets(%w[1 3])).to be_an_include 'VALUE 1 12 2000 13'
      expect(manager.gets(%w[1 3])).to be_an_include 'test object x'
      expect(manager.gets(%w[1 3])).to_not be_an_include 'VALUE 3'
      expect(manager.gets(%w[1 3])).to be_an_include "END\r\n"
      expect(manager.gets(%w[3 4])).not_to be_an_include 'VALUE'
      expect(manager.gets(%w[3 4])).to be_an_include "END\r\n"
    end
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
