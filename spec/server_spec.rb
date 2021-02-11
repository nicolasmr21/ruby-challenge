require_relative '../lib/server'
require_relative '../lib/client'

describe Server do

  before(:context) do
    @server = Server.new(3000)
    @client = Client.new('localhost', 3000)
  end

  context '#run_server' do
    before(:all) do
      @server.run_server
    end
    it 'should initialize the TCPServer' do
      expect(@server.server).to_not be_nil
      expect(@server.server).to be_an_instance_of(TCPServer)
    end
  end

  context '#accept_clients' do
    before(:all) do
      @server.accept_clients
    end
    it 'should' do
    end
  end

  context '#process' do
    it 'should' do
    end
  end

  after do
    @server.close
    @client.close
  end
end
