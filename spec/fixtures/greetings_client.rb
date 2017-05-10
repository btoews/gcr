require "greetings_services_pb"
require "greetings_server"

module Greetings
  class Client
    def self.stub
      @stub ||= Stub.new(Server::ADDRESS, :this_channel_is_insecure)
    end

    def self.hello(name)
      stub.hello(HelloRequest.new(
        name: name
      )).greeting
    end
  end
end
