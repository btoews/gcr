class GCR::Cassette
  attr_reader :data

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
    @data = {}
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
    @data = JSON.parse(File.read(@path))
  end

  # Persist this cassette.
  #
  # Returns nothing.
  def save
    File.open(@path, "w") do |f|
      f.write(JSON.pretty_generate(data))
    end
  end

  # Record all GRPC calls made while calling the provided block.
  #
  # Returns nothing.
  def record(&blk)
    install_record_hook
    blk.call
    save
  ensure
    remove_hook
  end

  # Play recorded GRPC responses.
  #
  # Returns nothing.
  def play(&blk)
    load
    install_play_hook
    blk.call
  ensure
    remove_hook
  end

  private

  def install_record_hook
    GCR.stub.class.class_eval do
      alias_method :orig_request_response, :request_response

      def request_response(*args)
        orig_request_response(*args).tap do |resp|
          key = GCR.serialize_request(*args)
          GCR.cassette.data[key] ||= []
          GCR.cassette.data[key] << GCR.serialize_response(resp)
        end
      end
    end
  end

  def install_play_hook
    GCR.stub.class.class_eval do
      alias_method :orig_request_response, :request_response

      def request_response(*args)
        key = GCR.serialize_request(*args)
        GCR.cassette.data[key] ||= []
        if resp = GCR.cassette.data[key].shift
          GCR.deserialize_response(resp)
        else
          raise GCR::NoRecording
        end
      end
    end
  end

  def remove_hook
    GCR.stub.class.class_eval do
      alias_method :request_response, :orig_request_response
    end
  end
end
