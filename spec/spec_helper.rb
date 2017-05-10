REPO_DIR = File.expand_path(File.join(__FILE__, "../.."))
TMP_DIR = File.join(REPO_DIR, "tmp")

# load lib
$LOAD_PATH << File.join(REPO_DIR, "lib")
require "gcr"

# load fixtures
$LOAD_PATH << File.join(REPO_DIR, "spec", "fixtures")
require "greetings_server"
require "greetings_client"

require "rspec"

RSpec.configure do |config|
  config.after(:suite) do
    Greetings::Server.stop if Greetings::Server.running?
    GCR::Cassette.delete_all
  end

  config.before(:each) do
    Greetings::Server.start unless Greetings::Server.running?
    GCR.cassette_dir = TMP_DIR
    GCR.stub = Greetings::Client.stub
    GCR::Cassette.delete_all
  end
end
