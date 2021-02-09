require_relative '../lib/memcached_manager'

describe MemcachedManager do

  manager = MemcachedManager.new
  manager.set('1', 12, 2000, 13, 'test object x')
  manager.set('2', 10, 3000, 13, 'test object y')

  context '#validate_request' do
    it 'should return true if is valid get' do
      expect(manager.validate_request('GET', %w[1], nil)).to be_truthy
    end
    it 'should return true if is valid gets' do
      expect(manager.validate_request('GETS', %w[1 2], nil)).to be_truthy
    end
    it 'should return true if is valid set' do
      expect(manager.validate_request('SET', %w[1 23 5000 7], 'newdata')).to be_truthy
    end
    it 'should return true if is valid add' do
      expect(manager.validate_request('ADD', %w[1 23 5000 7], 'newdata')).to be_truthy
    end
    it 'should return true if is valid replace' do
      expect(manager.validate_request('REPLACE', %w[1 23 5000 7], 'newdata')).to be_truthy
    end
    it 'should return true if is valid append' do
      expect(manager.validate_request('APPEND', %w[1 23 5000 7], 'newdata')).to be_truthy
    end
    it 'should return true if is valid prepend' do
      expect(manager.validate_request('PREPEND', %w[1 23 5000 7], 'newdata')).to be_truthy
    end
    it 'should return true if is valid cas' do
      expect(manager.validate_request('CAS', %w[1 23 5000 7 c0ceb73], 'newdata')).to be_truthy
    end
    it 'should return true if is not valid get' do
      expect(manager.validate_request('GET', '', nil)).to be_falsey
    end
    it 'should return true if is not valid gets' do
      expect(manager.validate_request('GETS', '', nil)).to be_falsey
    end
    it 'should return true if is not valid set' do
      expect(manager.validate_request('SET', %w[1 23 5000], 'newdata')).to be_falsey
      expect(manager.validate_request('SET', %w[1 23 5000], nil)).to be_falsey
    end
    it 'should return true if is not valid add' do
      expect(manager.validate_request('ADD', %w[1 5000], 'newdata')).to be_falsey
    end
    it 'should return true if is not valid replace' do
      expect(manager.validate_request('REPLACE', %w[1], 'newdata')).to be_falsey
    end
    it 'should return true if is not valid append' do
      expect(manager.validate_request('APPEND', '', 'newdata')).to be_falsey
    end
    it 'should return true if is not valid prepend' do
      expect(manager.validate_request('PREPEND', %w[1 23 5000 7 25 2], 'newdata')).to be_falsey
    end
    it 'should return true if is not valid cas' do
      expect(manager.validate_request('CAS', %w[1 23 5000 c0ceb73], 'newdata')).to be_falsey
      expect(manager.validate_request('CAS', %w[1 23 5000 7 c0ceb73], nil)).to be_falsey
      expect(manager.validate_request('CAS', '', 'newdata')).to be_falsey
    end
    it 'should return false if is not valid command' do
      expect(manager.validate_request('PUT', nil, nil)).to be_falsey
    end
  end

  context '#get' do
    it 'should return a item if it exists' do
      expect(manager.get(['1'])).to be_an_include 'VALUE 1 12 2000 13'
      expect(manager.get(['1'])).to be_an_include 'test object x'
      expect(manager.get(['1'])).to be_an_include "END\r\n"
    end
    it 'should return nothing if it does not exist' do
      expect(manager.get(['3'])).not_to be_an_include 'VALUE'
      expect(manager.get(['3'])).to be_an_include "END\r\n"
      expect(manager.get([''])).not_to be_an_include 'VALUE'
      expect(manager.get([''])).to be_an_include "END\r\n"
    end
  end

  context '#gets' do
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

  context '#set' do
    it 'should set a new item if it does not exist' do
      expect(manager.get(['3'])).to_not be_an_include('VALUE')
      expect(manager.set('3', 10, 50, 2, 'xy')).to be_an_include('STORED')
      expect(manager.get(['3'])).to be_an_include('VALUE')
    end
    it 'should modify the info if the item exist' do
      expect(manager.get(['2'])).to be_an_include('VALUE')
      expect(manager.set('2', 10, 50, 2, 'xy')).to be_an_include('STORED')
      expect(manager.get(['2'])).to be_an_include('VALUE 2 10 50 2')
    end
  end

  context '#add' do
    it 'should add a new item if it does not exist' do
      expect(manager.get(['4'])).to_not be_an_include('VALUE')
      expect(manager.add('4', 10, 50, 2, 'xy')).to be_an_include('STORED')
      expect(manager.get(['4'])).to be_an_include('VALUE')
    end
    it 'should not add if a item exist' do
      expect(manager.get(['2'])).to be_an_include('VALUE')
      expect(manager.add('2', 10, 50, 2, 'xy')).to be_an_include('NOT_STORED')
    end
  end

  context '#replace' do
    it 'should replace a item if it exists' do
      expect(manager.get(['2'])).to be_an_include('VALUE')
      expect(manager.replace('2', 11, 50, 2, 'xy')).to be_an_include('STORED')
      expect(manager.get(['2'])).to be_an_include('VALUE 2 11 50 2')
      expect(manager.get(['2'])).to be_an_include('xy')
    end
    it 'should not replace if a item does not exist' do
      expect(manager.get(['5'])).to_not be_an_include('VALUE')
      expect(manager.replace('5', 10, 50, 2, 'xy')).to be_an_include('NOT_STORED')
    end
  end

  context '#append' do
    it 'should append data on item if it exists' do
      manager.set('2', 10, 3000, 13, 'test object y')
      expect(manager.get(['2'])).to be_an_include('VALUE')
      expect(manager.append('2', 6, 'append')).to be_an_include('STORED')
      expect(manager.get(['2'])).to be_an_include('VALUE 2 10 3000 19')
      expect(manager.get(['2'])).to be_an_include('test object yappend')
    end
    it 'should not append if a item does not exist' do
      expect(manager.get(['6'])).to_not be_an_include('VALUE')
      expect(manager.append('6', 2, 'xy')).to be_an_include('NOT_STORED')
    end
  end

  context '#prepend' do
    it 'should prepend data on item if it exists' do
      manager.set('2', 10, 3000, 13, 'test object y')
      expect(manager.get(['2'])).to be_an_include('VALUE')
      expect(manager.prepend('2', 7, 'prepend')).to be_an_include('STORED')
      expect(manager.get(['2'])).to be_an_include('VALUE 2 10 3000 20')
      expect(manager.get(['2'])).to be_an_include('prependtest object y')
    end
    it 'should not prepend if a item does not exist' do
      expect(manager.get(['6'])).to_not be_an_include('VALUE')
      expect(manager.prepend('6', 2, 'xy')).to be_an_include('NOT_STORED')
    end
  end

  context '#cas' do
    it 'should update data of item if it exists and the cas key is the same' do
      item = manager.gets(['2']).split('\n')[0];
      cas = item.split[5]
      puts item, cas
      expect(cas).to_not be_nil
      expect(manager.cas('2', 2, 5000, 2, cas, 'xy')).to be_an_include('STORED')
      expect(manager.get(['2'])).to be_an_include('VALUE 2 2 5000 2')
      expect(manager.get(['2'])).to be_an_include('xy')
    end
    it 'should not update data of item if it exists and the cas key is not the same' do
      expect(manager.get(['2'])).to be_an_include('VALUE')
      expect(manager.cas('2', 2, 5000, 2, 'c0ceb73bd', 'xy')).to be_an_include('EXISTS')
    end
    it 'should not update data of item if it does not exists' do
      expect(manager.get(['10'])).to_not be_an_include('VALUE')
      expect(manager.cas('10', 2, 5000, 2, 'c0ceb73bd', 'xy')).to be_an_include('NOT_FOUND')
    end
  end
end
