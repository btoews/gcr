class GCR::Cassette
  VERSION = 2

  attr_reader :reqs

  # Delete all recorded cassettes.
  #
  # Returns nothing.
  def self.delete_all
    Dir[File.join(GCR.cassette_dir, "*.json")].each do |path|
      File.unlink(path)
    end
  end

  # Initialize a new cassette.
  #
  # name - The String name of the recording, from which the path is derived.
  #
  # Returns nothing.
  def initialize(name)
    @path = File.join(GCR.cassette_dir, "#{name}.json")
    @reqs = []
  end

  # Does this cassette exist?
  #
  # Returns boolean.
  def exist?
    File.exist?(@path)
  end

  # Load this cassette.
  #
  # Returns nothing.
  def load
    data = JSON.parse(File.read(@path))

    if data["version"] != VERSION
      raise "GCR cassette version #{data["version"]} not supported"
    end

    @reqs = data["reqs"].map do |req, resp|
      [GCR::Request.from_hash(req), GCR::Response.from_hash(resp)]
    end
  end

  # Persist this cassette.
  #
  # Returns nothing.
  def save
    File.open(@path, "w") do |f|
      f.write(JSON.pretty_generate(
        "version" => VERSION,
        "reqs"    => reqs,
      ))
    end
  end

  # Record all GRPC calls made while calling the provided block.
  #
  # Returns nothing.
  def record(&blk)
    start_recording
    blk.call
  ensure
    stop_recording
  end

  # Play recorded GRPC responses.
  #
  # Returns nothing.
  def play(&blk)
    start_playing
    blk.call
  ensure
    stop_playing
  end

  def start_recording
    GCR.stub.class.class_eval do
      alias_method :orig_request_response, :request_response

      def request_response(*args)
        orig_request_response(*args).tap do |resp|
          req = GCR::Request.from_proto(*args)
          if GCR.cassette.reqs.none? { |r, _| r == req }
            GCR.cassette.reqs << [req, GCR::Response.from_proto(resp)]
          end
        end
      end
    end
  end

  def stop_recording
    GCR.stub.class.class_eval do
      alias_method :request_response, :orig_request_response
    end
    save
  end

  def start_playing
    load

    GCR.stub.class.class_eval do
      alias_method :orig_request_response, :request_response

      def request_response(*args)
        req = GCR::Request.from_proto(*args)
        GCR.cassette.reqs.each do |other_req, resp|
          return resp.to_proto if req == other_req
        end
        raise GCR::NoRecording
      end
    end
  end

  def stop_playing
    GCR.stub.class.class_eval do
      alias_method :request_response, :orig_request_response
    end
  end

  def [](req)
    reqs.find { |r| r == req }
  end

  def []=(req, resp)
    reqs << [req, resp]
  end
end
