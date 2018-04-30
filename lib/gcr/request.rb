class GCR::Request
  def self.from_proto(route, proto_req, *_)
    new(
      "route"      => route,
      "class_name" => proto_req.class.name,
      "body"       => proto_req.to_json,
    )
  end

  def self.from_hash(hash_req)
    new(
      "route"      => hash_req["route"],
      "class_name" => hash_req["class_name"],
      "body"       => hash_req["body"],
    )
  end

  attr_reader :route, :class_name, :body

  def initialize(opts)
    @route      = opts["route"]
    @class_name = opts["class_name"]
    @body       = opts["body"]
  end

  def parsed_body
    @parsed_body ||= JSON.parse(body)
  end

  def to_json(*_)
    JSON.dump("route" => route, "class_name" => class_name, "body" => body)
  end

  def to_proto
    [route, Object.const_get(class_name).decode_json(body)]
  end

  def ==(other)
    return false unless route == other.route
    return false unless class_name == other.class_name

    parsed_body.keys.all? do |k|
      next true if GCR.ignored_fields.include?(k)
      parsed_body[k] == other.parsed_body[k]
    end
  end
end
