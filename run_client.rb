require_relative 'lib/client'

client = Client.new('localhost', 3000)
client.start
