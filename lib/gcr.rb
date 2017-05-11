module GCR
  Error = Class.new(StandardError)
  ConfigError = Class.new(Error)
  RunningError = Class.new(Error)
  NoRecording = Class.new(Error)

  # Specify where GCR should store cassettes.
  #
  # path - The String path to a directory.
  #
  # Returns nothing.
  def cassette_dir=(path)
    raise RunningError, "cannot configure GCR within #with_cassette block" if @running
    @cassette_dir = path
  end

  # Where GCR stores cassettes.
  #
  # Returns a String path to a directory. Raises ConfigError if not configured.
  def cassette_dir
    @cassette_dir || (raise ConfigError, "no cassette dir configured")
  end

  # Specify the stub to intercept calls to.
  #
  # stub - A GRPC::ClientStub instance.
  #
  # Returns nothing.
  def stub=(stub)
    raise RunningError, "cannot configure GCR within #with_cassette block" if @running
    @stub = stub
  end

  # The stub that is being mocked.
  #
  # Returns a A GRPC::ClientStub instance. Raises ConfigError if not configured.
  def stub
    @stub || (raise ConfigError, "no cassette dir configured")
  end

  def insert(name)
    @cassette = Cassette.new(name)
    if @cassette.exist?
      @cassette.start_playing
    else
      @cassette.start_recording
    end
  end

  def remove
    if @cassette.exist?
      @cassette.stop_playing
    else
      @cassette.stop_recording
    end
    @cassette = nil
  end

  def cassette
    @cassette
  end

  # If a cassette with the given name exists, play that cassette for the
  # provided block. Otherwise, record a cassette with the provided block.
  #
  # Returns nothing.
  def with_cassette(name, &blk)
    @cassette = Cassette.new(name)
    if @cassette.exist?
      @cassette.play(&blk)
    else
      @cassette.record(&blk)
    end
  ensure
    @cassette = nil
  end

  def serialize_request(route, req, marshal, unmarshal, metadata)
    JSON.dump(
      "route" => route,
      "req"   => Base64.strict_encode64(req.to_proto)
    )
  end

  def serialize_response(resp)
    JSON.dump(
      "type"  => resp.class.descriptor.name,
      "buf" => Base64.strict_encode64(resp.to_proto)
    )
  end

  def deserialize_response(str)
    hsh = JSON.parse(str)
    klass = Google::Protobuf::DescriptorPool.generated_pool.lookup(hsh["type"]).msgclass
    klass.decode(Base64.strict_decode64(hsh["buf"]))
  end

  extend self
end

require "json"
require "base64"
require "gcr/cassette"
