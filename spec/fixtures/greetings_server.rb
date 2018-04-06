require "greetings_services_pb"

module Greetings
  class Server < Service
    ADDRESS = "127.0.0.1:5567"

    def self.running?
      !!@pid
    end

    def self.start
      raise "server already running" if running?

      @pid = Process.fork do
        s = GRPC::RpcServer.new
        s.add_http2_port(ADDRESS, :this_port_is_insecure)
        s.handle(new)
        s.run
      end
    end

    def self.stop
      raise "server not running" unless running?

      Process.kill("TERM", @pid)
      Process.waitpid(@pid)
      @pid = nil
    end

    def hello(req, _call)
      HelloResponse.new(
        greeting: "resp #{increment_counter} — hello #{req.name}"
      )
    end

    def increment_counter
      if defined?(@counter)
        @counter += 1
      else
        @counter = 0
      end

      return @counter
    end
  end
end
