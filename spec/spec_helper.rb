# load lib
$LOAD_PATH << File.expand_path(File.join(__FILE__, "../../lib"))
require "gcr"

# load fixtures
$LOAD_PATH << File.expand_path(File.join(__FILE__, "../fixtures"))
require "greetings_server"
require "greetings_client"

require "rspec"

RSpec.configure do |config|
  config.before(:suite) do
    Greetings::Server.start
  end

  config.after(:suite) do
    Greetings::Server.stop
  end
end
