Gem::Specification.new do |s|
  s.name     = "gcr"
  s.summary  = "GRPC test helpers"
  s.version  = "1.0.2"
  s.authors  = ["mastahyeti"]
  s.homepage = "https://github.com/mastahyeti/gcr"
  s.licenses = ["MIT"]

  s.add_runtime_dependency "google-protobuf", "~> 3.7"

  s.add_development_dependency "grpc", "~> 1.55"
  s.add_development_dependency "rspec", "~> 3.12"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"

  s.files = Dir["./lib/**/*.rb"]

  s.require_paths = ["lib"]
end
