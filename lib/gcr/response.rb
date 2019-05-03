class GCR::Response
  def self.from_proto(proto_resp)
    new(
      "class_name" => proto_resp.class.name,
      "body"       => proto_resp.to_json(emit_defaults: true)
    )
  end

  def self.from_hash(hash_resp)
    new(
      "class_name" => hash_resp["class_name"],
      "body"       => hash_resp["body"],
    )
  end

  attr_reader :class_name, :body

  def initialize(opts)
    @class_name = opts["class_name"]
    @body = opts["body"]
  end

  def parsed_body
    @parsed_body ||= JSON.decode(body)
  end

  def to_json(*_)
    JSON.dump("class_name" => class_name, "body" => body)
  end

  def to_proto
    Object.const_get(class_name).decode_json(body)
  end
end
