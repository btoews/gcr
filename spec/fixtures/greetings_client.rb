require "greetings_services_pb"
require "greetings_server"

module Greetings
  class Client
    def self.stub
      @stub ||= Stub.new(Server::ADDRESS, :this_channel_is_insecure)
    end

    def self.hello(name, request_id="")
      stub.hello(HelloRequest.new(
        name: name,
        request_id: request_id,
      )).greeting
    end
  end
end
