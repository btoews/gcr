Gem::Specification.new do |s|
  s.name    = "gcr"
  s.summary = "GRPC test helpers"
  s.version = "0.0.1"
  s.authors = ["mastahyeti"]

  s.add_development_dependency "grpc", "~> 1.2.5"
  s.add_development_dependency "pry", "~> 0.10.4"
  s.add_development_dependency "rspec", "~> 3.5.0"
  s.add_development_dependency "rspec-mocks", "~> 3.5.0"

  s.files = Dir["./lib/**/*.rb"]

  s.require_paths = ["lib"]
end
