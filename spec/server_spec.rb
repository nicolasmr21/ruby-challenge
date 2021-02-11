require_relative '../lib/server'
require_relative '../lib/client'
require_relative '../lib/utils'

describe Server do

  before(:context) do
    @client = TestClient.new
    @socket = @client.start
  end

  context 'accept new clients' do
    it 'should initialize connection socket correctly' do
      expect(@socket).to be_an_instance_of(TCPSocket)
    end
    it 'should accept a new client connection' do
      expect(@socket.closed?).to be_falsey
    end
  end

  context 'handle client and process commands' do
    before(:all) do
      @socket.write("set 1 23 20 7\r\nnewdata\r\n")
      @socket.write("get 1\r\n")
      @socket.write("add 1 5000\r\nnewdata\r\n")
      @response_set = @socket.gets
      @response_get = @socket.gets + @socket.gets + @socket.gets
      @response_add = @socket.gets
    end
    it 'should process valid commands' do
      expect(@response_set).to include Utils::STORED
      expect(@response_get).to include "VALUE 1 23 20 7\r\nnewdata\r\n"
    end
    it 'should show client error for not valid command' do
      expect(@response_add).to include Utils::CLIENT_ERROR
    end
  end
end

class TestClient
  def start
    TCPSocket.new('localhost', 3000)
  end
end
