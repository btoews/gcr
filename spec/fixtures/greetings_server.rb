require "greetings_services_pb"

module Greetings
  class Server < Service
    ADDRESS = "127.0.0.1:5567"

    def self.start
      raise "server already running" if @pid

      @pid = Process.fork do
        s = GRPC::RpcServer.new
        s.add_http2_port(ADDRESS, :this_port_is_insecure)
        s.handle(new)
        s.run
      end
    end

    def self.stop
      raise "server not running" unless @pid

      Process.kill("TERM", @pid)
      Process.waitpid(@pid)
      @pid = nil
    end

    def hello(req, _call)
      HelloResponse.new(
        greeting: "hello #{req.name}"
      )
    end
  end
end
