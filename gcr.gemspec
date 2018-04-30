Gem::Specification.new do |s|
  s.name     = "gcr"
  s.summary  = "GRPC test helpers"
  s.version  = "1.0.0"
  s.authors  = ["mastahyeti"]
  s.homepage = "https://github.com/mastahyeti/gcr"
  s.licenses = ["MIT"]

  s.add_runtime_dependency "google-protobuf", "~> 3.5", ">= 3.3.0"

  s.add_development_dependency "grpc", "~> 1.10", ">= 1.2.5"
  s.add_development_dependency "rspec", "~> 3.5", ">= 3.5.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"

  s.files = Dir["./lib/**/*.rb"]

  s.require_paths = ["lib"]
end
