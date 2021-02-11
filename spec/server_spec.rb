require_relative '../lib/server'
require_relative '../lib/client'

describe Server do

  before(:context) do
    @server = Server.new(3000)
    @client = Client.new('localhost', 3000)
  end

  context '#run_server' do
    it 'should' do
    end
  end

  context '#accept_clients' do
    it 'should' do
    end
  end

  context '#start' do
    it 'should' do
    end
  end

  context '#process' do
    it 'should' do
    end
  end
end
